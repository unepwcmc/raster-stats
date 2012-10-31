# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-005.vm.brightbox.net"

## List of servers
server "unepwcmc-005.vm.brightbox.net", :app, :web, :db, :primary => true


namespace :deploy do
  namespace :rake_tasks do
    task :singleton, :roles => :db, :only => {:primary => true} do
      puts "do nothing"
    end
  end
end
