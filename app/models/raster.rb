class Raster < ActiveRecord::Base
  attr_accessible :display_name, :basename, :file_name, :input_loc, :pixel_size

  after_create :generate_rasters

  FILE_TYPE = 'HFA'
  OUTPUT_EXTENSION = '.img'
  GDALTRANSLATE = 'gdal_translate'

  def calculate_extra_attributes_and_save
    if input_loc.starts_with?('http')
      self.basename = File.basename((URI.parse(self.input_loc).path))
      get_file = "wget -O #{INPUT_PATH}#{self.basename} #{self.input_loc}"
    elsif !File.file?(self.input_loc)
      self.errors.add(:input_loc, "file does not exist.")
      return false
    else
      self.basename = File.basename(self.input_loc)
      get_file = "cp #{self.input_loc} #{INPUT_PATH}"
    end
    system(get_file)
    self.pixel_size = Raster.pixel_size(INPUT_PATH+self.basename)
    self.file_name = self.basename + OUTPUT_EXTENSION
    self.save
  end

  def self.pixel_size file_path
    file = Gdal::Gdal.open(file_path)
    file.get_geo_transform()[1]
  end

  def generate_rasters
    no_data = "gdalwarp #{INPUT_PATH}#{basename} #{INPUT_PATH}ndata_#{basename} -dstnodata 0"
    generate_high = "#{GDALTRANSLATE} -of #{FILE_TYPE} #{INPUT_PATH}ndata_#{basename}  #{HIGH_RES_PATH}#{basename}#{OUTPUT_EXTENSION}"
    generate_medium = "#{GDALTRANSLATE} -outsize #{MEDIUM_RES_VALUE}% #{MEDIUM_RES_VALUE}% -of #{FILE_TYPE} #{INPUT_PATH}ndata_#{basename}  #{MEDIUM_RES_PATH}#{basename}#{OUTPUT_EXTENSION}"
    generate_low = "#{GDALTRANSLATE} -outsize #{LOW_RES_VALUE}% #{LOW_RES_VALUE}% -of #{FILE_TYPE} #{INPUT_PATH}ndata_#{basename} #{LOW_RES_PATH}#{basename}#{OUTPUT_EXTENSION}"
    system(no_data)
    system(generate_high)
    system(generate_medium)
    system(generate_low)
  end
end
