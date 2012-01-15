require 'cfpropertylist'
require 'siriproxy/interpret_siri'
require 'pp'

class SiriProxy::Connection < EventMachine::Connection
  include EventMachine::Protocols::LineText2
  
  attr_accessor :validation_object,:host,:auth_grabber,:other_connection, :name, :ssled, :output_buffer, :input_buffer, :processed_headers, :unzip_stream, :zip_stream, :consumed_ace, :unzipped_input, :unzipped_output, :last_ref_id, :plugin_manager, :is_4S, :sessionValidationData, :speechId, :assistantId, :aceId, :speechId_avail, :assistantId_avail, :validationData_avail

  def last_ref_id=(ref_id)
    @last_ref_id = ref_id
    self.other_connection.last_ref_id = ref_id if other_connection.last_ref_id != ref_id
  end
  
  #ReadSavedData
  SpeechIDFILE = File.expand_path("~/.siriproxy/speechId")
  AssistantIdFILE = File.expand_path("~/.siriproxy/assistantId")
  SessionValidationDataFILE = File.expand_path("~/.siriproxy/sessionValidationData")

	def get_speechId
	  begin
	    File.open(SpeechIDFILE, "r") {|file| self.speechId = file.read}
		  self.speechId_avail = true
	  rescue SystemCallError
		  puts "[ERROR - SiriProy] Error opening the speechId file. Connect an iPhone4S first or create them manually!"
	  end
	end

	def get_assistantId
	    begin
		File.open(AssistantIdFILE, "r") {|file| self.assistantId = file.read}
		self.assistantId_avail = true
	    rescue SystemCallError
		puts "[ERROR - SiriProxy] Error opening the assistantId file. Connect an iPhone4S first or create them manually!"
	    end
	end

	def get_validationData
    begin   
      @validation = Validation.one_valid   
      if @validation
        self.sessionValidationData= @validation.key 
        self.validationData_avail = true
        self.validation_object = @validation
        puts "[Keys - SiriProy] Key Loaded from Database for Validation Data"
      else 
        self.validationData_avail = false
      end
    
    rescue SystemCallError,NoMethodError
      puts "[ERROR - SiriProxy] Error opening the sessionValidationData  file. Connect an iPhone4S first or create them manually!"
    end
	end  

  def checkHave4SData
     if self.speechId != nil and self.assistantId != nil and self.sessionValidationData != nil
        #writing keys
        File.open(SpeechIDFILE,"w") do |file|
          file.write(self.speechId)
        end
        File.open(AssistantIdFILE,"w") do |file|
          file.write(self.assistantId)
        end
        File.open(SessionValidationDataFILE,"wb") do |file|
	        file.write(self.sessionValidationData)
	        #file.write("".unpack('H*').join(""))
        end
        puts "[Info - SiriProxy] Keys written to file"
     end

    if self.speechId != nil and self.assistantId != nil and self.sessionValidationData != nil

      user = User.find_by_speech_id_and_assistant_id(self.speechId,self.assistantId)
      validation = Validation.find_by_key(self.sessionValidationData)

      if user
        if validation
          puts "[Info - SiriProxy] Already have this sessionValidationData"
        else
          puts "[Info - SiriProxy] New Validation Data"
          validation = Validation.new
          validation.key = self.sessionValidationData
          validation.user = user
          validation.save
        end
      else
        $logger.info "[Info - SiriProxy] Received validation key but without user"
      end
    end
  end

	def plist_blob(string)
	 string = [string].pack('H*')
	 #string = [string]
	 string.blob = true
	 string
	end
	
  def initialize(options)
    super
    self.host = ""
    self.auth_grabber = options[:auth_grabber]
    self.processed_headers = false
    self.output_buffer = ""
    self.input_buffer = ""
    self.unzipped_input = ""
    self.unzipped_output = ""
    self.unzip_stream = Zlib::Inflate.new
    self.zip_stream = Zlib::Deflate.new
    self.consumed_ace = false
    self.is_4S = false 			#bool if its iPhone 4S
    self.sessionValidationData = nil	#validationData
    self.speechId = nil			#speechID
    self.assistantId = nil			#assistantID
    self.speechId_avail = false		#speechID available
    self.assistantId_avail = false		#assistantId available
    self.validationData_avail = false	#validationData available
    puts "[Info - SiriProxy] Got a inbound Connection!"   
  end

  def post_init
    self.ssled = false
  end

  def ssl_handshake_completed
    self.ssled = true
    
    puts "[Info - #{self.name}] SSL completed for #{self.name}" if $LOG_LEVEL > 1
  end
  
  def receive_line(line) #Process header
    puts "[Header - #{self.name}] #{line}" if $LOG_LEVEL > 2
    
    if line.include? "Host"
      host = line.delete "Host: "
      host = URI.parse("https://#{host}").host.split('.').first
      self.host = host
    end

    if(line == "") #empty line indicates end of headers
      puts "[Debug - #{self.name}] Found end of headers" if $LOG_LEVEL > 3
      set_binary_mode
      self.processed_headers = true
		##############
		#Check for User Agent
		elsif line.match(/^User-Agent:/)
			puts "[Info - SiriProxy] Original: ] " + line
			if line.match(/iPhone4,1;/)
				puts "[Info - SiriProxy] iPhone 4S connected"
				self.is_4S = true
			else
				puts "[Info - SiriProxy] - iPhone 4 or other non 4S connected. Using saved keys"
				self.is_4S = false
				#maybe change header... but not for now
				line = "User-Agent: Assistant(iPhone/iPhone4,1; iPhone OS/5.0.1/9A405) Ace/1.0"
				puts "[Info - SiriProxy] Changed Header: " + line
			end
		
    end  
    self.output_buffer << (line + "\x0d\x0a") #Restore the CR-LF to the end of the line
    
    flush_output_buffer()
  end

  def receive_binary_data(data)
    self.input_buffer << data
    
    ##Consume the "0xAACCEE02" data at the start of the stream if necessary (by forwarding it to the output buffer)
    if(self.consumed_ace == false)
      self.output_buffer << input_buffer[0..3]
      self.input_buffer = input_buffer[4..-1]
      self.consumed_ace = true;
    end
    
    process_compressed_data()
    
    flush_output_buffer()
  end
  
  def flush_output_buffer
    return if output_buffer.empty?
  
    if other_connection.ssled
      puts "[Debug - #{self.name}] Forwarding #{self.output_buffer.length} bytes of data to #{other_connection.name}" if $LOG_LEVEL > 5
      #puts  self.output_buffer.to_hex if $LOG_LEVEL > 5
      other_connection.send_data(output_buffer)
      self.output_buffer = ""
    else
      puts "[Debug - #{self.name}] Buffering some data for later (#{self.output_buffer.length} bytes buffered)" if $LOG_LEVEL > 5
      #puts  self.output_buffer.to_hex if $LOG_LEVEL > 5
    end
  end

  def process_compressed_data    
    self.unzipped_input << unzip_stream.inflate(self.input_buffer)
    self.input_buffer = ""
    puts "========UNZIPPED DATA (from #{self.name} =========" if $LOG_LEVEL > 5
    puts unzipped_input.to_hex if $LOG_LEVEL > 5
    puts "==================================================" if $LOG_LEVEL > 5
    
    while(self.has_next_object?)
      object = read_next_object_from_unzipped()
      
      if(object != nil) #will be nil if the next object is a ping/pong
        new_object = prep_received_object(object) #give the world a chance to mess with folks
    
        inject_object_to_output_stream(new_object) if new_object != nil #might be nil if "the world" decides to rid us of the object
      end
    end
  end

  def has_next_object?
    return false if unzipped_input.empty? #empty
    unpacked = unzipped_input[0...5].unpack('H*').first
    return true if(unpacked.match(/^0[34]/)) #Ping or pong
    
    if unpacked.match(/^[0-9][15-9]/)
      puts "ROGUE PACKET!!! WHAT IS IT?! TELL US!!! IN IRC!! COPY THE STUFF FROM BELOW"
      puts unpacked.to_hex
    end 
    objectLength = unpacked.match(/^0200(.{6})/)[1].to_i(16)
    return ((objectLength + 5) < unzipped_input.length) #determine if the length of the next object (plus its prefix) is less than the input buffer
  end

  def read_next_object_from_unzipped
    unpacked = unzipped_input[0...5].unpack('H*').first
    info = unpacked.match(/^0(.)(.{8})$/)
    
    if(info[1] == "3" || info[1] == "4") #Ping or pong -- just get these out of the way (and log them for good measure)
      object = unzipped_input[0...5]
      self.unzipped_output << object
      
      type = (info[1] == "3") ? "Ping" : "Pong"      
      puts "[#{type} - #{self.name}] (#{info[2].to_i(16)})" if $LOG_LEVEL > 3
      self.unzipped_input = unzipped_input[5..-1]
      
      flush_unzipped_output()
      return nil
    end
  
    object_size = info[2].to_i(16)
    prefix = unzipped_input[0...5]
    object_data = unzipped_input[5...object_size+5]
    self.unzipped_input = unzipped_input[object_size+5..-1]

    parse_object(object_data)
  end
  
  
  def parse_object(object_data)
    plist = CFPropertyList::List.new(:data => object_data)    
    object = CFPropertyList.native_types(plist.value)
    
    object
  end
  
  def inject_object_to_output_stream(object)
    if object["refId"] != nil && !object["refId"].empty?
      @block_rest_of_session = false if @block_rest_of_session && self.last_ref_id != object["refId"] #new session
      self.last_ref_id = object["refId"] 
    end
    
    puts "[Info - Forwarding object to #{self.other_connection.name}] #{object["class"]}" if $LOG_LEVEL > 1
    
    object_data = object.to_plist(:plist_format => CFPropertyList::List::FORMAT_BINARY)

    #Recalculate the size in case the object gets modified. If new size is 0, then remove the object from the stream entirely
    obj_len = object_data.length
    
    if(obj_len > 0)
      prefix = [(0x0200000000 + obj_len).to_s(16).rjust(10, '0')].pack('H*')
      self.unzipped_output << prefix + object_data
    end
    
    flush_unzipped_output()
  end
  
  def flush_unzipped_output
    self.zip_stream << self.unzipped_output
    self.unzipped_output = ""
    self.output_buffer << zip_stream.flush
    
    flush_output_buffer()
  end
  
  def prep_received_object(object)
  	if object["properties"] != nil
			if object["properties"]["validationData"] !=nil #&& !object["properties"]["validationData"].empty?
				if self.is_4S
        				puts "[Info - SiriProxy] using iPhone 4S validationData and saving it"
					self.sessionValidationData = object["properties"]["validationData"].unpack('H*').join("")
					checkHave4SData
    				else
    					get_validationData
    					if self.validationData_avail
        					puts "[Info - SiriProxy] using saved validationData"
        					object["properties"]["validationData"] = plist_blob(self.sessionValidationData)
        				else
        					puts "[Info - SiriProxy] no validationData available :("
        				end
				end
			end
			if object["properties"]["sessionValidationData"] !=nil #&& !object["properties"]["sessionValidationData"].empty?
				if self.is_4S
        				puts "[Info -  SiriProxy] using iPhone 4S validationData and saving it"
        				self.sessionValidationData = object["properties"]["sessionValidationData"].unpack('H*').join("")
        				checkHave4SData
    				else
    					get_validationData
    					if  self.validationData_avail
        					puts "[Info - SiriProxy] using saved validationData"
        					object["properties"]["sessionValidationData"] = plist_blob(self.sessionValidationData)
        				else
        					puts "[Info - SiriProxy] no validationData available :("
        				end
    				end
			end
			if object["properties"]["speechId"] !=nil #&& !object["properties"]["speechId"].empty?
				if self.is_4S
					puts "[Info - SiriProxy] using iPhone 4S speechID and saving it"
        				self.speechId = object["properties"]["speechId"]
        				checkHave4SData
				else
					if object["properties"]["speechId"].empty?
						get_speechId
						if speechId_avail
							puts "[Info - SiriProxy] using saved speechID:  #{self.speechId}"
        						object["properties"]["speechId"] = self.speechId
        					else
        						puts "[Info - SiriProxy] no speechId available :("
        					end
        				else
        					puts "[Info - SiriProxy] using speechID sent by iPhone: #{object["properties"]["speechId"]}"
                  self.speechId = object["properties"]["speechId"]
        				end
    				end
			end
			if object["properties"]["assistantId"] !=nil #&& !object["properties"]["assistantId"].empty?
				if self.is_4S
					puts "[Info - SiriProxy] using iPhone 4S  assistantId and saving it"
					self.assistantId = object["properties"]["assistantId"]
					checkHave4SData
    				else
    					if object["properties"]["assistantId"].empty?
    						get_assistantId
    						if assistantId_avail
        						puts "[Info - SiriProxy] using saved assistantID - #{self.assistantId}"
        						object["properties"]["assistantId"] = self.assistantId
        					else
        						puts "[Info - SiriProxy] no assistantId available :("
        					end
        				else
        					puts "[Info - SiriProxy] using assistantID sent by iPhone: #{object["properties"]["assistantId"]}"
                  self.assistantId = object["properties"]["assistantId"]
        				end
				end
			end
		end
    if object["refId"] == self.last_ref_id && @block_rest_of_session
      puts "[Info - Dropping Object from Guzzoni] #{object["class"]}" if $LOG_LEVEL > 1
      pp object if $LOG_LEVEL > 3
      return nil
    end
  
    puts "[Info - #{self.name}] Received Object: #{object["class"]}" if $LOG_LEVEL == 1
    puts "[Info - #{self.name}] Received Object: #{object["class"]} (group: #{object["group"]})" if $LOG_LEVEL == 2
    puts "[Info - #{self.name}] Received Object: #{object["class"]} (group: #{object["group"]}, ref_id: #{object["refId"]}, ace_id: #{object["aceId"]})" if $LOG_LEVEL > 2
    pp object if $LOG_LEVEL > 3
    
    #keeping this for filters
    new_obj = received_object(object)
    if new_obj == nil 
      puts "[Info - Dropping Object from #{self.name}] #{object["class"]}" if $LOG_LEVEL > 1
      pp object if $LOG_LEVEL > 3
      return nil
    end

    #block the rest of the session if a plugin claims ownership
    speech = SiriProxy::Interpret.speech_recognized(object)
    if speech != nil
      inject_object_to_output_stream(object)
      block_rest_of_session if plugin_manager.process(speech) 
      return nil
    end


    #speech = SiriProxy::Interpret.unknown_intent(object)
    #if speech != nil
    #  inject_object_to_output_stream(object)
    #  block_rest_of_session if plugin_manager.process(speech) 
    #  return nil
    #end

    
    
    #object = new_obj if ((new_obj = SiriProxy::Interpret.unknown_intent(object, self, plugin_manager.method(:unknown_command))) != false)    
    #object = new_obj if ((new_obj = SiriProxy::Interpret.speech_recognized(object, self, plugin_manager.method(:speech_recognized))) != false)
    
    object
  end  
  
  #Stub -- override in subclass
  def received_object(object)
    
    object
  end 

end
