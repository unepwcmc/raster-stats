# Primary domain name of your application. Used in the Apache configs
set :domain, "raster-stats.unep-wcmc.org"

## List of servers
server "raster-stats", :app, :web, :db, :primary => true
