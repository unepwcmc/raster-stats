class Starspan
  require 'csv'
  require 'json'

  STARSPAN = 'starspan'
  PIXELS_PROCESSED = 2_300_000

  def initialize(options)
    @raster = Raster.find(options[:raster_id])
    @operation = options[:operation]
    @identifier = Time.now.getutc.to_i
    @polygon = JSON.parse(options[:polygon])
    @polygon_file = polygon_to_file(options[:polygon])
    @raster_path, @res_used = choose_raster(@polygon["features"][0]["properties"]["AREA"])
  end

  def choose_operation
    if ["sum", "avg", "max", "min"].include?(@operation)
      send("generate_#{@operation}")
    else 
      {:error => 'The operation is not valid' }
    end
  end

  def polygon_to_file polygon
    polygon_file = "#{POLYGON_PATH}#{@identifier}.geojson"
    File.open(polygon_file, 'w'){|f| f.write(polygon)}
    polygon_file
  end

  def choose_raster(area)
    high_res_path = HIGH_RES_PATH + @raster.file_name
    medium_res_path = MEDIUM_RES_PATH + @raster.file_name
    low_res_path = LOW_RES_PATH + @raster.file_name
    high_pixel_area = @raster.pixel_size*@raster.pixel_size
    medium_pixel_area = high_pixel_area*MEDIUM_RES_VALUE/100*MEDIUM_RES_VALUE/100
    if area/high_pixel_area < PIXELS_PROCESSED
      [high_res_path, "high"]
    elsif area.to_f/medium_pixel_area < PIXELS_PROCESSED
      [medium_res_path, "medium"]
    else
      [low_res_path, "low"]
    end
  end

  def run_analysis
    if choose_operation
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
  end

  def generate_max
    call = "#{STARSPAN} --vector #{@polygon_file} --raster #{HIGH_RES_PATH + @raster.file_name} --stats max --out-type table --out-prefix #{RESULTS_PATH} --summary-suffix #{@identifier}.csv"
    puts call
    system(call)
  end

  def generate_min
    call = "#{STARSPAN} --vector #{@polygon_file} --raster #{HIGH_RES_PATH + @raster.file_name} --stats min --out-type table --out-prefix #{RESULTS_PATH} --summary-suffix #{@identifier}.csv"
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
              entry[header] = row[header].to_f * @raster.pixel_size*(100/(MEDIUM_RES_VALUE))
            elsif @res_used == 'low'
              entry[header] = row[header].to_f * @raster.pixel_size*(100/(LOW_RES_VALUE))
            else
              entry[header] = row[header]
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
