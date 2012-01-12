set :application, "siribrazil"
set :repository,  "git@github.com:raphaelcosta/siriproxy.git "
set :scm, :git

set :deploy_to, "/users/ubuntu/siriproxy"

role :web, "siribrazil.com"                          # Your HTTP server, Apache/etc
role :app, "siribrazil.com"                          # This may be the same as your `Web` server
role :db,  "siribrazil.com", :primary => true # This is where Rails migrations will run


set :user, "ubuntu"
set :use_sudo, false
set :rails_env, "production"

ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/raphaelcosta.pem"]

set :deploy_via, :remote_cache
# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end