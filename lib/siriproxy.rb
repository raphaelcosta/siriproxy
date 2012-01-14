require 'eventmachine'
require 'zlib'
require 'pp'
require 'pg'
require 'active_record'
require 'require_all'
require 'sms'
require 'logger'
require_all 'models'

class String
  def to_hex(seperator=" ")
    bytes.to_a.map{|i| i.to_s(16).rjust(2, '0')}.join(seperator)
  end
end

class SiriProxy
  
  def initialize(options)
    # @todo shouldnt need this, make centralize logging instead
    $LOG_LEVEL = $APP_CONFIG.log_level.to_i

    #$APP_CONFIG.port = options[:auth_grabber] ? 443 : 1000

    $logger = Logger.new(STDOUT)

    #ActiveRecord Initialization
    ActiveRecord::Base.logger = $logger
    ActiveRecord::Base.establish_connection(
      :adapter => 'postgresql',
      :host => $APP_CONFIG.database['host'],
      :database => $APP_CONFIG.database['database'],
      :username => $APP_CONFIG.database['user'],
      :password => $APP_CONFIG.database['password'],
      :pool => 20
    )

    if Validation.active.count > 0      
      @@availablekeys = Validation.active.count     
      $logger.info "[Keys - SiriProxy] Available Keys in Database: [#{Validation.active.count}]"
    else
      $logger.info "[Keys - SiriProxy] Warning starting Server with no key in Database!"
    end

    EventMachine.run do
      begin
        puts "Starting SiriProxy on port #{$APP_CONFIG.port}.."
        EventMachine::start_server('0.0.0.0', $APP_CONFIG.port, SiriProxy::Connection::Iphone,options) { |conn|
          $stderr.puts "start conn #{conn.inspect}"
          conn.plugin_manager = SiriProxy::PluginManager.new()
          conn.plugin_manager.iphone_conn = conn
        }
        puts "Server is Up and Running"

        EventMachine::PeriodicTimer.new(30){
          active_connections = EM.connection_count          
          c = Configuration.first
          c ||= Configuration.new
          if active_connections != c.active_connections
            c.active_connections = active_connections
            c.save
          end
          puts "[Info - SiriProxy] Active connections [#{active_connections}]"
        }

      rescue RuntimeError => err
        if err.message == "no acceptor"
          raise "Cannot start the server on port #{$APP_CONFIG.port} - are you root, or have another process on this port already?"
        else
          raise
        end
      end
    end
  end
end
