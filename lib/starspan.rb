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
    return @resolution if defined?(@resolution)

    polygon = JSON.parse(@polygon)
    area = polygon["features"][0]["properties"]["AREA"].to_f
    pixels_processed = 2_300_000
    high_pixel_area = @raster.pixel_size * @raster.pixel_size
    medium_pixel_area = high_pixel_area * (50/100) * (50/100)

    if area / high_pixel_area < pixels_processed
      @resolution = :high
    elsif area / medium_pixel_area < pixels_processed
      @resolution = :medium
    else
      @resolution = :low
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
    if File.exist?("#{self.class.results_path}#{@identifier}.csv")
      list = []
      csv = CSV.read("#{self.class.results_path}#{@identifier}.csv", {headers: true})
      csv.each do |row|
        entry = {}
        csv.headers.each do |header|
          if header.starts_with?(@operation.capitalize)
            #FIXME calculations need to be checked
            if resolution_used == :high || @operation != 'sum'
              entry["value"] = row[header]
            else
              if resolution_used == :medium
                entry["value"] = row[header].to_f * @raster.pixel_size * (100/50)
              elsif resolution_used == :low
                entry["value"] = row[header].to_f * @raster.pixel_size * (100/10)
              end
            end
          end
        end
        list << entry
      end

      return list
    else
      {error: 'The application failed to process the analysis statistics...'}
    end
  end
end
