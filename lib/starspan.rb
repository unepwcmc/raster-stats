class Starspan
  require 'csv'
  require 'json'

  attr_reader :identifier, :raster, :operation, :polygon

  def initialize(raster, operation, polygon)
    @identifier = Time.now.getutc.to_i
    @raster = raster
    @operation = operation
    @polygon = polygon
  end

  def result
    if respond_to?(@operation)
      send(@operation)
      return results_to_hash
    else
      {error: 'The application failed when trying to run the analysis...'}
    end
  end

  def resolution_used
    return @resolution if defined? @resolution

    pixels_processed = 2_300_000
    area = self.class.calculate_area_of_polygon(JSON.parse(@polygon))

    Raster::RESOLUTIONS.each do |resolution, percentage|
      pixel_area = @raster.pixel_size**2 * (percentage / 100)**2
      return (@resolution = resolution) if((area / pixel_area) < pixels_processed)
    end
  end

  [:avg, :sum, :min, :max].each do |operation|
    define_method operation do
      raster = ([:min, :max].include?(operation) ? @raster.path(:high, true) : @raster.path(resolution_used, true))
      cmd = "#{self.class.starspan_command} --vector #{vector_file.path} --raster #{raster} --stats #{operation} --out-type table --out-prefix #{self.class.results_path}/ --summary-suffix #{@identifier}.csv"
      puts cmd
      system(cmd)
    end
  end

  class << self
    def results_path
      Rails.root.join('tmp', 'starspan').tap do |dir|
        Dir.mkdir dir unless File.directory? dir
      end
    end

    def starspan_command
      `which starspan`.delete("\n")
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
