class Starspan 
  require 'csv'
  require 'json'

  STARSPAN = 'starspan'
  LOW_RES_PATH = 'raster/low_resolution/'
  MEDIUM_RES_PATH = 'raster/medium_resolution/'
  HIGH_RES_PATH = 'raster/high_resolution/'
  RESULTS_PATH= 'results/raster_'
  STATS =  "avg sum"

  attr_accessor :polygon_file, :polygon, :identifier, :raster_path

  def initialize(options)
    @polygon_file = options[:polygon_file]
    @polygon = options[:polygon]
    @identifier = options[:identifier]
    @raster_path = choose_raster(@polygon["features"][0]["properties"]["AREA"])
  end

  def choose_raster(area)
    if area > 9_000_000_000_000
      LOW_RES_PATH + 'carbon.tif'
    elsif area > 600_000_000_000
      MEDIUM_RES_PATH + 'carbon.tif'
    else
      HIGH_RES_PATH + 'carbon.tif'
    end
  end

  def run_analysis
    if generate_stats
      results_to_json
    else
      {:error => 'The application failed to run your analysis' }.to_json
    end
  end

  private

  def generate_stats
    call = "#{STARSPAN} --vector '#{polygon_file}' --raster #{raster_path} --stats #{STATS} --out-prefix #{RESULTS_PATH} --out-type table --summary-suffix #{identifier}.csv"
    puts call
    system(call)
  end

  def results_to_json
    if File.file?("#{RESULTS_PATH}#{identifier}.csv")
      puts "File generated successfuly"
      csv_table = CSV.read("#{RESULTS_PATH}#{identifier}.csv", {headers: true})
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
      {:error => 'The application failed to process the analysis stats.'}.to_json
    end
  end
end		
