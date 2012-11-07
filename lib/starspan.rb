class Starspan
  require 'csv'
  require 'json'

  STARSPAN = 'starspan'
  RASTER_PATH = '../raster/'
  RESULTS_PATH= 'results/raster_'
  POLYGON_PATH = 'polygons/'
  STATS = "avg sum"
  PIXELS_PROCESSED = 2_300_000

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

  def self.choose_raster(area)
    raster_hash = JSON.parse(File.read(RASTER_PATH + 'raster_info.json'))
    high_pixel_area = rasteri["pixel_size"]*rasteri["pixel_size"]
    medium_pixel_area=high_pixel_area*rasteri["medium_res_value"]/100*rasteri["medium_res_value"]/100
    if area/high_pixel_area < PIXELS_PROCESSED
      raster_hash["high_res_path"] + rasteri["file_name"]
    elsif area/medium_pixel_area < PIXELS_PROCESSED
      raster_hash["medium_res_path"] + rasteri["file_name"]
    else
      raster_hash["low_res_path"] + rasteri["file_name"]
    end
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
