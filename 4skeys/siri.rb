God.watch do |w|
  w.name = "siri"
  w.start = "rvmsudo ruby /home/ec2-user/Siri/SiriProxy/start.rb"
  
  w.pid_file = File.join(File.dirname("__FILE__"), "log/siri.pid")
  w.log = File.join(File.dirname("__FILE__"), "log/siri.log")
  w.behavior(:clean_pid_file)
end
