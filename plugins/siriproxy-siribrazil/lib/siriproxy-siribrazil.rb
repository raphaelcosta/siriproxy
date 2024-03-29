#encoding: utf-8
require 'cora'
require 'siri_objects'
require 'pp'

#######
# This is a "hello world" style plugin. It simply intercepts the phrase "test siri proxy" and responds
# with a message about the proxy being up and running (along with a couple other core features). This 
# is good base code for other plugins.
# 
# Remember to add other plugins to the "config.yml" file if you create them!
######

class SiriProxy::Plugin::SiriBrazil < SiriProxy::Plugin
  def initialize(config)
    #if you have custom configuration options, process them here!
  end

  filter "SetActivationToken", direction: :from_guzzoni do |object|
    @validation = connection.validation_object
    puts '[Info - SiriProxy] Received token'
    if @validation
      connection.activation_token_received = true
      @validation.total_tokens_recieved+=1
      @validation.save
    end
  end

  filter "GetSessionCertificateResponse", direction: :from_guzzoni do |object|
    @validation = connection.validation_object
    puts '[Info - SiriProxy] Received GetSessionCertificateResponse'
    connection.certificate_response = true
  end
  
  filter "FinishSpeech", direction: :from_iphone do |object|
    puts '[Info - SiriProxy] Started FinishSpeech'
    @validation = connection.validation_object
    if connection.certificate_response == true && connection.activation_token_received == false && connection.validationData_avail == true && connection.createassistant == false
      puts '[Info - SiriProxy] Recorded FinishSpeech'

      if @validation.total_finishspeech_requests >= 3
        if @validation.total_tokens_recieved == 0
          @validation.expire
          @validation.save
          puts '[Key - SiriProxy] Probably the validation expired!'
          connection.get_validationData
        else
          @validation.total_finishspeech_requests=0
          @validation.total_tokens_recieved=0
          @validation.save
        end
      else
        @validation.total_finishspeech_requests+=1
        @validation.save
        puts '[Info - SiriProxy] Recorded FinishSpeech'
      end
    end
  end

  filter "SessionValidationFailed", direction: :from_guzzoni do |object|
    @validation = connection.validation_object
    if @validation
      @validation.expire
      @validation.save
      connection.get_validationData
    end

  end

  #NEW GENERATED IDS
  filter "SpeechRecognized", direction: :from_guzzoni do |object|
    unless @current_state == :authorized
      puts "Verifying Device"

      #Verify if this user have an udid
      if self.connection.udid
        @device = Device.find_by_udid(self.connection.udid)

        #user already have a udid registered
        if @device
          unless @device.user
            unless @device.token
              @device.generate_token
              @device.save
            end
            say "Dispositivo não autorizado! Código de autorização: #{@device.token}", spoken: "Device not authorized"
            request_completed
            false
            self.connection.close_connection true
          else
            #Create History
            h  = AccessHistory.new
            h.device = @device
            h.ip = self.connection.ip
            h.save
            set_state :authorized
          end
        else
        #user dont have udid registered
          if self.connection.speechId and connection.assistantId
            @device = Device.find_or_create_by_speechid_and_assistantid(connection.speechId,connection.assistantId)
            @device.udid = self.connection.udid
            @device.save
            unless @device.user
              unless @device.token
                @device.generate_token
                @device.save
              end

              say "Dispositivo não autorizado! Código de autorização: #{@device.token}", spoken: "Device not authorized"
              request_completed
              false
              self.connection.close_connection true
            else
              #Create History
              h  = AccessHistory.new
              h.device = @device
              h.ip = self.connection.ip
              h.save
              set_state :authorized
            end
          else
            self.connection.close_connection true
          end
        end
      else
        #USER DONT HAVE UDID NORMAL UPDATE
        if self.connection.speechId and connection.assistantId
          @device = Device.find_or_create_by_speechid_and_assistantid(connection.speechId,connection.assistantId)
          unless @device.user
            unless @device.token
              @device.generate_token
              @device.save
            end

            say "Dispositivo não autorizado! Código de autorização: #{@device.token}", spoken: "Device not authorized"
            request_completed
            false
            self.connection.close_connection true
          else
            #Create History
            h  = AccessHistory.new
            h.device = @device
            h.ip = self.connection.ip
            h.save
            set_state :authorized
          end
        else
          self.connection.close_connection true
        end

      end

    end

    false unless @current_state == :authorized
    
  end


  
  #Demonstrate that you can have Siri say one thing and write another"!
  listen_for /you dont say/i do
    say "Sometimes I don't write what I say", spoken: "Sometimes I don't say what I write"
  end 

  #demonstrate state change
  listen_for /siri proxy test state/i do
    set_state :some_state #set a state... this is useful when you want to change how you respond after certain conditions are met!
    say "I set the state, try saying 'confirm state change'"
    
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
  
  listen_for /confirm state change/i, within_state: :some_state do #this only gets processed if you're within the :some_state state!
    say "State change works fine!"
    set_state nil #clear out the state!
    
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
  
  #demonstrate asking a question
  listen_for /test question/i do
    response = ask "Is this thing working?" #ask the user for something
    
    if(response =~ /yes/i) #process their response
      say "Great!" 
    else
      say "You could have just said 'yes'!"
    end
    
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
  
  #demonstrate capturing data from the user (e.x. "Siri proxy number 15")
  listen_for /siri proxy number ([0-9,]*[0-9])/i do |number|
    say "Detected number: #{number}"
    
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
  
  #demonstrate injection of more complex objects without shortcut methods.
  listen_for /test/i do
    add_views = SiriAddViews.new
    add_views.make_root(last_ref_id)
    map_snippet = SiriMapItemSnippet.new
    map_snippet.items << SiriMapItem.new
    utterance = SiriAssistantUtteranceView.new("Testing map injection!")
    add_views.views << utterance
    add_views.views << map_snippet
    
    #you can also do "send_object object, target: :guzzoni" in order to send an object to guzzoni
    send_object add_views #send_object takes a hash or a SiriObject object
    
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
end
