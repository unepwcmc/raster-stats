require 'rubygems'
require 'sinatra'
require "json"
require "csv"

STARSPAN = 'starspan'
LOW_RES_PATH = 'raster/low_resolution/'
MEDIUM_RES_PATH = 'raster/medium_resolution/'
HIGH_RES_PATH = 'raster/high_resolution/'
RESULTS_PATH= 'results/raster_'

get '/' do
  'hello world'
end

get '/stats/:polygon' do
	TIME = Time.now.getutc.to_i
  content_type :json
  polygon_file = "tmp/user_polygon_#{TIME}.geojson"
  File.open(polygon_file, 'w'){|f| f.write(params[:polygon])}
  polygon = JSON.parse(params[:polygon])
  area= polygon["features"][0]["properties"]["AREA"]
  if area > 9_000_000_000_000
    raster_path = LOW_RES_PATH + 'carbon.tif'
  elsif area > 600_000_000_000
    raster_path = MEDIUM_RES_PATH + 'carbon.tif'
  else
    raster_path = HIGH_RES_PATH + 'carbon.tif'
  end
  stats = "avg sum"
  call = "#{STARSPAN} --vector '#{polygon_file}' --raster #{raster_path} --stats #{stats} --out-prefix #{RESULTS_PATH} --out-type table --summary-suffix #{TIME}.csv"
  puts call
  system(call)
	if File.file?("#{RESULTS_PATH}#{TIME}.csv")
		puts "File generated successfuly"
    csv_table = CSV.read("#{RESULTS_PATH}#{TIME}.csv", {headers: true})
    list = []
		csv_table.each do |row|
			entry = {}
			csv_table.headers.each do |header|
				entry[header] = row[header]
			end
			list << entry
		end
		result = JSON.pretty_generate(list)
		puts result
		result
	else 
    {}
	end
end
