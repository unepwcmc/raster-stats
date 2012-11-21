class Starspan
  require 'json'

  attr_reader :identifier, :raster, :operation, :polygon

  def initialize(raster, operation, polygon)
    @identifier = Time.now.getutc.to_i
    @raster = raster
    @operation = operation
    @polygon = polygon
  end

  def result
    send(@operation)
  end

  [:avg, :sum, :min, :max].each do |operation|
    raster = Proc.new { @raster.path }
    stats = operation

    raster = Proc.new { @raster.path(:high) } if [:min, :max].include?(operation)

    stats = "avg sum" if [:avg, :sum].include?(operation)

    define_method operation do
      system("#{self.class.starspan_command} --vector #{vector_file.path} --raster #{raster} --stats #{stats} --out-type table --out-prefix #{self.class.results_path} --summary-suffix #{@identifier}.csv")
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
      @vector_file = Tempfile.new "raster_#{@raster.id}_operation_#{@operation.id}.geojson"
      @vector_file.write(@polygon)
      @vector_file.rewind
    end

    @vector_file
  end
end
