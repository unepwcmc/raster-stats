require 'rubygems'
require 'sinatra'
require "json"

STARSPAN = 'starspan'
LOW_RES_PATH = 'raster/low_resolution/'
RESULTS_PATH = 'results/'

get '/' do
  'hello world'
end

get '/stats/:polygon' do
  polygon_file = "user_polygon.geojson"
  File.open(polygon_file, 'w'){|f| f.write(params[:polygon])}
  polygon = JSON.parse(params[:polygon])
  #json.to_s + "<br />" + json["features"].to_s #["properties"]["area"].to_i
  area= polygon["features"][0]["properties"]["AREA"]
  "imprimir " + area.to_s
  if area > 9_000_000_000_000
  raster_path = LOW_RES_PATH + 'carbon.tif'
  end
  stats = "avg sum"
  call = "#{STARSPAN} --vector '#{polygon_file}' --raster #{raster_path} --stats #{stats} --out-prefix raster --out-type table --summary-suffix _stats.csv"
  puts call
  system call
  
end
