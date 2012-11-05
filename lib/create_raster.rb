class CreateRaster

  require 'gdal-ruby/gdal'
  require 'json'

  INPUT_FILE = 'input.tif'
  INPUT_PATH = '../raster/input/'
  HIGH_RES_PATH = '../raster/high_resolution/'
  MEDIUM_RES_PATH = '../raster/medium_resolution/'
  LOW_RES_PATH = '../raster/low_resolution/'
  FILE_TYPE = 'HFA'
  GDALTRANSLATE = 'gdal_translate'
  RESULT_FILE = 'result.img'
  MEDIUM_RES_VALUE = 50
  LOW_RES_VALUE = 10

  def self.pixel_size
    file = Gdal::Gdal.open( INPUT_PATH+INPUT_FILE )
    geotransform = file.get_geo_transform()
    pixel_high_res = geotransform[1]
    pixel_medium_res = geotransform[1]*100/MEDIUM_RES_VALUE
    pixel_low_res = geotransform[1]*100/LOW_RES_VALUE
  end

  def self.generate_rasters
    generate_high = "#{GDALTRANSLATE} -of #{FILE_TYPE} #{INPUT_PATH}#{INPUT_FILE}  #{HIGH_RES_PATH}#{RESULT_FILE}"
    generate_medium = "#{GDALTRANSLATE} -outsize #{MEDIUM_RES_VALUE}% #{MEDIUM_RES_VALUE}% -of #{FILE_TYPE} #{INPUT_PATH}}#{INPUT_FILE}  #{MEDIUM_RES_PATH}#{RESULT_FILE}"
    generate_low = "#{GDALTRANSLATE} -outsize #{LOW_RES_VALUE}% #{LOW_RES_VALUE}% -of #{FILE_TYPE} #{INPUT_PATH}}#{INPUT_FILE} #{LOW_RES_PATH}#{RESULT_FILE}"
    system(generate_high)
    system(generate_medium)
    system (generate_low)
  end
end
