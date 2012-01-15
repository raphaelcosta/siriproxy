#####
  # This is the connection to the iPhone
#####
class SiriProxy::Connection::Iphone < SiriProxy::Connection
  def initialize(options)
    puts "Create server for iPhone connection"
    super
    self.name = "iPhone"
  end

  def post_init
    super
    if $APP_CONFIG.development
      puts 'Development Mode'
      start_tls(:cert_chain_file  => File.expand_path("~/.siriproxy/cert/dev/server.passless.crt"),
              :private_key_file => File.expand_path("~/.siriproxy/cert/dev/server.passless.key"),
              :verify_peer      => false)
    else
      start_tls(:cert_chain_file  => File.expand_path("~/.siriproxy/cert/new/server.passless.crt"),
                :private_key_file => File.expand_path("~/.siriproxy/cert/new/server.passless.key"),
                :verify_peer      => false)
    end
  end


  def ssl_handshake_completed
    super
    self.other_connection = EventMachine.connect('guzzoni.apple.com', 443, SiriProxy::Connection::Guzzoni,{})
    self.plugin_manager.guzzoni_conn = self.other_connection
    other_connection.other_connection = self #hehe
    other_connection.plugin_manager = plugin_manager
  end
  
  def received_object(object)
    return plugin_manager.process_filters(object, :from_iphone)

    #plugin_manager.object_from_client(object, self)
  end
end
