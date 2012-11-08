# Need to Adapt to different rasters input
# Delete repeated lines on json
class CreateRaster

  require 'gdal-ruby/gdal'
  require 'json'

  #INPUT_FILE = 'input'
  #INPUT_EXTENSION = '.tif'
  INPUT_PATH = 'raster/input/'
  HIGH_RES_PATH = 'raster/high_resolution/'
  MEDIUM_RES_PATH = 'raster/medium_resolution/'
  LOW_RES_PATH = 'raster/low_resolution/'
  FILE_TYPE = 'HFA'
  OUTPUT_EXTENSION = '.img'
  GDALTRANSLATE = 'gdal_translate'
  MEDIUM_RES_VALUE = 50
  LOW_RES_VALUE = 10

  def initialize(options)
    @input_file = options[:filename]
  end

  def pixel_size
    file = Gdal::Gdal.open( INPUT_PATH + @input_file )
    geotransform = file.get_geo_transform()
    pixel_hash = {
      "file_name" => @input_file + OUTPUT_EXTENSION,
      "pixel_size" => geotransform[1],
      "high_res_path" => HIGH_RES_PATH,
      "medium_res_path" => MEDIUM_RES_PATH,
      "low_res_path" => LOW_RES_PATH,
      "medium_res_value" => MEDIUM_RES_VALUE,
      "low_res_value" => LOW_RES_VALUE
    }
    File.open("raster/raster_info.json","a") do |f|
      f.write(pixel_hash.to_json)
    end
  end

  def generate_rasters
    generate_high = "#{GDALTRANSLATE} -of #{FILE_TYPE} #{INPUT_PATH}#{@input_file}  #{HIGH_RES_PATH}#{@input_file}#{OUTPUT_EXTENSION}"
    generate_medium = "#{GDALTRANSLATE} -outsize #{MEDIUM_RES_VALUE}% #{MEDIUM_RES_VALUE}% -of #{FILE_TYPE} #{INPUT_PATH}#{@input_file}  #{MEDIUM_RES_PATH}#{@input_file}#{OUTPUT_EXTENSION}"
    generate_low = "#{GDALTRANSLATE} -outsize #{LOW_RES_VALUE}% #{LOW_RES_VALUE}% -of #{FILE_TYPE} #{INPUT_PATH}#{@input_file} #{LOW_RES_PATH}#{@input_file}#{OUTPUT_EXTENSION}"
    system(generate_high)
    system(generate_medium)
    system(generate_low)
  end

end
