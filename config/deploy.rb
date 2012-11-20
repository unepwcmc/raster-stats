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
