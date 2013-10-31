class Starspan
  require 'csv'
  require 'json'
  require 'timeout'

  attr_reader :identifier, :raster, :operation, :polygon

  def initialize(raster, operation, polygon, moll)
    @identifier = Time.now.getutc.to_i
    @raster = raster
    @operation = operation
    @polygon = polygon
    @moll = moll
  end

  def result
    if respond_to?(@operation)
      pid = send(@operation)
      begin
        Timeout.timeout(120) do
          puts 'waiting for the process to end'
          Process.wait(pid)
          puts 'process finished in time'
          return results_to_hash
        end
      rescue Timeout::Error
        puts 'process not finished in time, killing it'
        Process.kill('KILL', pid)
      end
    else
      {error: 'The application failed when trying to run the analysis...'}
    end
  end

  def resolution_used
    return @resolution if defined? @resolution
    pixels_processed = @moll ? 0.1 : 200_000
    parsed_json = JSON.parse(@polygon)
    begin
      p = parsed_json["features"][0]["properties"]
      json_a = @moll ? p["AREA_MOLL"] : p["AREA"]
    rescue
      json_a = nil
    end
    area = json_a ? json_a : self.class.calculate_area_of_polygon(parsed_json)
  
    Raster::RESOLUTIONS.each do |resolution, percentage|
      pixel_area = @raster.pixel_size**2 / (percentage / 100.0)**2

      return (@resolution = resolution) if ((area / pixel_area) < pixels_processed)
    end
    return :low
  end

  [:avg, :sum, :min, :max].each do |operation|
    define_method operation do
      raster = ([:min, :max].include?(operation) ? @raster.path(:high, true) : @raster.path(resolution_used, true))
      cmd = "#{self.class.starspan_command} --vector #{vector_file.path} --raster #{raster} --stats #{operation} --out-type table --out-prefix #{self.class.results_path}/ --summary-suffix #{@identifier}.csv"
      puts cmd
      Process.spawn(cmd)
    end
  end

  class << self
    def results_path
      Rails.root.join('tmp', 'starspan').tap do |dir|
        Dir.mkdir dir unless File.directory? dir
      end
    end

    def starspan_command
      `which starspan2`.delete("\n")
    end
    
    def calculate_area_of_polygon(polygon)
      polygon_coordinates = polygon["features"][0]["geometry"]["coordinates"][0]
      sum = 0

      (0...(polygon_coordinates.size - 1)).each do |i|
        sum += (polygon_coordinates[i][0]*polygon_coordinates[i+1][1]) - (polygon_coordinates[i][1]*polygon_coordinates[i+1][0])
      end

      (sum / 2.0).abs
    end
  end

  private

  def vector_file
    unless defined? @vector_file
      @vector_file = Tempfile.new "raster_#{@raster.id}_operation_#{@operation}.geojson"
      @vector_file.write(@polygon)
      @vector_file.rewind
    end

    @vector_file
  end

  def results_to_hash
    csv_file = "#{self.class.results_path}/#{@identifier}.csv"

    if File.exist?(csv_file)
      csv = CSV.read(csv_file, {headers: true})
      result = csv[0]["#{@operation}_Band1"].to_f

      if @operation == 'sum'
        result *= (100 / Raster::RESOLUTIONS[resolution_used])**2
      end

      {value: result}
    else
      {error: 'The application failed to process the analysis statistics...'}
    end
  end
end
