class EmailNotifier < Bluepill::Trigger
  def initialize(process, options = {})
    @email = options.delete(:email)
    @notify_on = options.delete(:notify_on)
    super
  end
  def notify(transition)
    if @notify_on.include?(transition.to_name)
      IO.popen("sendmail -t", "w") do |x|
        x.puts "To: #{@email}"
        #your other mail headers
        x.puts
        x.puts "Your process #{self.process.name} has restarted at #{Time.now}"
      end
    end
  end
end