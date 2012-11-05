class Starspan
  require 'csv'
  require 'json'

  STARSPAN = 'starspan'
  LOW_RES_PATH = 'raster/low_resolution/'
  MEDIUM_RES_PATH = 'raster/medium_resolution/'
  HIGH_RES_PATH = 'raster/high_resolution/'
  RESULTS_PATH= 'results/raster_'
  POLYGON_PATH = 'polygons/'
  STATS =  "avg sum"

  def initialize(options)
    @identifier = Time.now.getutc.to_i
    @polygon = JSON.parse(options[:polygon])
    @polygon_file = polygon_to_file(options[:polygon])
    @raster_path = choose_raster(@polygon["features"][0]["properties"]["AREA"])
  end

  def polygon_to_file polygon
    polygon_file = "#{POLYGON_PATH}#{@identifier}.geojson"
    File.open(polygon_file, 'w'){|f| f.write(polygon)}
    polygon_file
  end

  def choose_raster(area)
    rasteri = JSON.parse(File.read('create_raster.rb', 'rb').read)
    if area/(rasteri["pixel_high_res"]*rasteri["pixel_high_res"]) < 2_300_000
      HIGH_RES_PATH + 'raster.tif'
    elsif area/(rasteri["pixel_medium_res"]*rasteri["pixel_medium_res"]) < 2_300_000
      MEDIUM_RES_PATH + 'raster.tif'
    else
      LOW_RES_PATH + 'raster.tif'
    end
    puts
  end

  def run_analysis
    if generate_stats
      results_to_hash
    else
      {:error => 'The application failed to run your analysis' }
    end
  end

  private

  def generate_stats
    call = "#{STARSPAN} --vector '#{@polygon_file}' --raster #{@raster_path} --stats #{STATS} --out-type table --out-prefix #{RESULTS_PATH} --summary-suffix #{@identifier}.csv"
    puts call
    system(call)
  end

  def results_to_hash
    if File.file?("#{RESULTS_PATH}#{@identifier}.csv")
      puts "File generated successfuly"
      csv_table = CSV.read("#{RESULTS_PATH}#{@identifier}.csv", {headers: true})
      list = []
      csv_table.each do |row|
        entry = {}
        csv_table.headers.each do |header|
          entry[header] = row[header]
        end
        list << entry
      end
      #result = JSON.pretty_generate(list)
      puts list
      list
    else 
      {:error => 'The application failed to process the analysis stats.'}
    end
	end
end		
