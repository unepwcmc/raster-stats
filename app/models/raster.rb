class Raster < ActiveRecord::Base
  require 'gdal-ruby/gdal'
  require 'builder'
  require 'nokogiri'

  attr_accessible :display_name, :source_file

  validates :display_name, uniqueness: true

  COLOR_MAX = '#000000'
  COLOR_MIN = '#FFFFFF'

  def path(filename = 'default', img_extension = false)
    "#{rasters_path}/#{filename}.tif#{(img_extension && '.img') || ''}"
  end

  class << self
    def gdal_translate_command
      `which gdal_translate`.delete("\n")
    end

    def gdalwarp_command
      `which gdalwarp`.delete("\n")
    end

    def python_command
      `which python`.delete("\n")
    end
  end

  #TODO: add background jobs
  def create_tile(z, x, y)
    generate_xml unless File.exists?("#{rasters_path}/style.xml")
    system "#{self.class.python_command} #{Rails.root.join('lib')}/create_tiles.py --xml #{rasters_path}/style.xml --tiles #{raster_tiles_path} -z #{z} -x #{x} -y #{y}"
  end

  private

  def extract_pixel_size
    Gdal::Gdal.open(path).get_geo_transform()[1]
  end

  def extract_min_max_pixel
    Gdal::Gdal.open(path).get_raster_band(1).compute_raster_min_max()
  end

  def rasters_path
    Rails.root.join('lib', 'rasters', self.id.to_s).tap do |dir|
      FileUtils.mkdir_p dir unless File.directory? dir
    end
  end

  def raster_tiles_path
    Rails.root.join('public', 'tiles', self.id.to_s).tap do |dir|
      FileUtils.mkdir_p dir unless File.directory? dir
    end
  end

  def generate_rasters
    system "#{self.class.gdalwarp_command} -dstnodata 0 #{path} #{path('ndata')}"
    system "#{self.class.gdal_translate_command} -of HFA #{path('ndata')} #{path('high', true)}"
    system "#{self.class.gdal_translate_command} -outsize 50% 50% -of HFA #{path('ndata')} #{path('medium', true)}"
    system "#{self.class.gdal_translate_command} -outsize 10% 10% -of HFA #{path('ndata')} #{path('low', true)}"
  end

  def generate_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      map = xml.Map {
        style = xml.Style {
          xml.Rule {
            raster_symbolizer = xml.RasterSymbolizer {
              raster_colorizer = xml.RasterColorizer {
                stop = xml.stop
                stop['color'] = COLOR_MIN
                stop['value'] = extract_min_max_pixel[0].to_s

                stop = xml.stop
                stop['color'] = COLOR_MAX
                stop['value'] = extract_min_max_pixel[1].to_s
              }

              raster_colorizer['default-mode'] = 'linear'
              raster_colorizer['epsilon'] = '0.001'
            }

            raster_symbolizer['opacity'] = '1'
          }
        }
        style['name'] = 'raster'

        layer = xml.Layer {
          xml.StyleName 'raster'
          xml.Datasource {
            parameter = xml.Parameter path('ndata')
            parameter['name'] = 'file'
            parameter = xml.Parameter 'gdal'
            parameter['name'] = 'type'
            parameter = xml.Parameter '1'
            parameter['name'] = 'band'
          }
        }
        layer['name'] = 'raster'
      }

      map['background-color'] = 'steelblue'
      map['srs'] = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
    end

    File.open("#{rasters_path}/style.xml", 'w') do |f|
      f.puts builder.to_xml
    end
  end

  #TODO: add background jobs
  def create_tiles
    generate_xml unless File.exists?("#{rasters_path}/style.xml")
    system "#{self.class.python_command} #{Rails.root.join('lib')}/create_tiles.py --xml #{rasters_path}/style.xml --tiles #{raster_tiles_path}"
  end

  # TODO: add background jobs
  after_create do
    if source_file =~ /^https?:\/\//
      system("wget -O #{path} #{source_file}")
    elsif File.file?(source_file)
      system("cp #{source_file} #{path}")
    else
      raise(RuntimeError, "File not found...")
    end

    self.update_attribute(:pixel_size, extract_pixel_size)

    generate_rasters
    create_tiles
  end
end
