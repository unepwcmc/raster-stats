class Raster < ActiveRecord::Base
  require 'gdal-ruby/gdal'

  attr_accessible :name, :source_file
  attr_reader :pixel_size

  def path(filename = 'default', img_extension = false)
    "#{rasters_path}#{filename}.tif#{img_extension && '.img'}"
  end

  class << self
    def gdal_translate_command
      `which gdal_translate`.delete("\n")
    end

    def gdalwarp_command
      `which gdalwarp`.delete("\n")
    end
  end

  private

  def extract_pixel_size
    Gdal::Gdal.open(path).get_geo_transform()[1]
  end

  def rasters_path
    Rails.root.join('lib', 'rasters', self.id).tap do |dir|
      Dir.mkdir dir unless File.directory? dir
    end
  end

  def generate_rasters
    system "#{gdalwarp_command} -dstnodata 0 #{path} #{path('ndata')}"
    system "#{gdal_translate_command} -of HFA #{path('ndata')} #{path('high', true)}"
    system "#{gdal_translate_command} -outsize 50% 50% -of HFA #{path('ndata')} #{path('medium', true)}"
    system "#{gdal_translate_command} -outsize 10% 10% -of HFA #{path('ndata')} #{path('low', true)}"
  end

  after_create do
    # TODO: add background jobs
    if source_file =~ /^https?:\/\//
      system("wget -O #{path} #{source_file}")
    elsif File.file?(source_file)
      system("cp #{source_file} #{path}"
    else
      raise(RuntimeError, "File not found...")
    end

    self.update_attribute(:pixel_size, extract_pixel_size)
    
    generate_rasters
  end
end
