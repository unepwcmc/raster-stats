set :stages, %w(production staging)
set :default_stage, 'production'
require 'capistrano/ext/multistage'

# RVM bootstrap
#$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
#require "rvm/capistrano"                               # Load RVM's capistrano plugin.
#set :rvm_ruby_string, '1.9.3-head@sponsor'             # Or whatever env you want it to run in.
#set :rvm_type, :user

set :application, "raster-stats"
set :repository,  "https://github.com/unepwcmc/raster-stats.git"
#set :repository, "git@github.com:unepwcmc/raster-stats.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :branch, "master"
set :scm_username, "unepwcmc-read"
set :git_enable_submodules, 1
default_run_options[:pty] = true                                                  # Must be set for the password prompt from git to work

set :deploy_to, "~/#{application}"
#set :use_sudo, false

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# bundler bootstrap
require 'bundler/capistrano'

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# SQLite3 configuration
set(:shared_database_path) {"#{shared_path}/databases"}

namespace :sqlite3 do
  desc "Generate a database configuration file"
  task :build_configuration, :roles => :db do
    db_options = {
      "adapter"  => "sqlite3",
      "database" => "#{shared_database_path}/production.sqlite3"
    }
    config_options = {"production" => db_options}.to_yaml
    put config_options, "#{shared_path}/config/sqlite_config.yml"
  end
 
  desc "Links the configuration file"
  task :link_configuration_file, :roles => :db do
    run "ln -nsf #{shared_path}/config/sqlite_config.yml #{release_path}/config/database.yml"
  end
 
  desc "Make a shared database folder"
  task :make_shared_folder, :roles => :db do
    run "mkdir -p #{shared_database_path}"
  end
end

after "deploy:setup", "sqlite3:make_shared_folder"
after "deploy:setup", "sqlite3:build_configuration"
 
after "deploy:update_code", "sqlite3:link_configuration_file"
