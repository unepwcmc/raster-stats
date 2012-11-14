class Starspan
  require 'csv'
  require 'json'

  STARSPAN = 'starspan'
  RASTER_PATH = 'raster/'
  INFO_PATH = 'info/'
  RESULTS_PATH= 'results/raster_'
  POLYGON_PATH = 'polygons/'
  PIXELS_PROCESSED = 2_300_000

  def initialize(options)
    @raster = options[:raster]
    @stat = options[:stat]
    @identifier = Time.now.getutc.to_i
    @polygon = JSON.parse(options[:polygon])
    @polygon_file = polygon_to_file(options[:polygon])
    @raster_hash = JSON.parse(File.read(RASTER_PATH + INFO_PATH + @raster + '.json'))
    @raster_path, @res_used = choose_raster(@polygon["features"][0]["properties"]["AREA"])
  end

  def choose_stat
    #sites = %w[stackoverflow stackexchange serverfault]
    #=> ["stackoverflow", "stackexchange", "serverfault"]
    if ["sum", "avg", "max", "min"].include?(@stat)
      send("generate_#{@stat}")
    else 
      {:error => 'The statistic is not valid' }
    end
  end

  def polygon_to_file polygon
    polygon_file = "#{POLYGON_PATH}#{@identifier}.geojson"
    File.open(polygon_file, 'w'){|f| f.write(polygon)}
    polygon_file
  end

  def choose_raster(area)
    high_res_path = @raster_hash["high_res_path"] + @raster_hash["file_name"]
    medium_res_path = @raster_hash["medium_res_path"] + @raster_hash["file_name"]
    low_res_path = @raster_hash["low_res_path"] + @raster_hash["file_name"]
    high_pixel_area = @raster_hash["pixel_size"]*@raster_hash["pixel_size"]
    medium_pixel_area = high_pixel_area*@raster_hash["medium_res_value"]/100*@raster_hash["medium_res_value"]/100
    if area/high_pixel_area < PIXELS_PROCESSED
      [high_res_path, "high"]
    elsif area/medium_pixel_area < PIXELS_PROCESSED
      [medium_res_path, "medium"]
    else
      [low_res_path, "low"]
    end
  end

  def run_analysis
    if choose_stat
      results_to_hash
    else
      {:error => 'The application failed to run your analysis' }
    end
  end

  private
  def generate_avg
    call = "#{STARSPAN} --vector #{@polygon_file} --raster #{@raster_path} --stats avg sum --out-type table --out-prefix #{RESULTS_PATH} --summary-suffix #{@identifier}.csv"
    puts call
    system(call)
  end


  def generate_sum
    call = "#{STARSPAN} --vector #{@polygon_file} --raster #{@raster_path} --stats avg sum --out-type table --out-prefix #{RESULTS_PATH} --summary-suffix #{@identifier}.csv"
    puts
    system(call)
  #  if @res_used == "high"
  #    system(call)
  #  elsif @res_used == "medium"
  #    system(call)*@raster_hash["pixel_size"]*(100/(@raster_hash["medium_res_value"]))
  #  else
  #    system(call)*@raster_hash["pixel_size"]*(100/(@raster_hash["low_res_value"]))
  #  end
  end

  def generate_max
    call = "#{STARSPAN} --vector #{@polygon_file} --raster #{@raster_hash["high_res_path"] + @raster_hash["file_name"]} --stats max --out-type table --out-prefix #{RESULTS_PATH} --summary-suffix #{@identifier}.csv"
    puts call
    system(call)
  end

  def generate_min
    call = "#{STARSPAN} --vector #{@polygon_file} --raster #{@raster_hash["high_res_path"] + @raster_hash["file_name"]} --stats min --out-type table --out-prefix #{RESULTS_PATH} --summary-suffix #{@identifier}.csv"
    puts call
    system(call)
  end

  def results_to_hash
    if File.file?("#{RESULTS_PATH}#{@identifier}.csv")
      puts "File generated successfuly"
      csv_table = CSV.read("#{RESULTS_PATH}#{@identifier}.csv", {:headers => true})
      list = []
      csv_table.each do |row|
        entry = {}
        csv_table.headers.each do |header|
          if header.start_with?("sum")
            if @res_used == 'medium'
              entry[header] = row[header].to_f * @raster_hash["pixel_size"]*(100/(@raster_hash["medium_res_value"]))
            elsif @res_used == 'low'
              entry[header] = row[header].to_f * @raster_hash["pixel_size"]*(100/(@raster_hash["low_res_value"]))
            end
          else
            entry[header] = row[header]
          end
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
