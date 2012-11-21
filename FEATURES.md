* Check if the raster file was deleted when deleting the raster
* Save the raster file with the id of the raster being created
* Nested routes for operations under rasters
* Store all of the files uploaded/generated on a different folder - not on lib/assets
* Remove SQLite dependency - install MySQL(?)
* Download file with background jobs
* Make sure you cannot edit name of operation if it is KEY
* On config/application.rb check if we really need to require 'gdal-ruby/gdal'????
* Remove initializers/constants.rb when not needed anymore
* Rewrite raster model
* Remove calculate_extra_attributes_and_save from rasters_controller
