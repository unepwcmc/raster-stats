class AddColorZoomToRaster < ActiveRecord::Migration
  def change
    add_column :rasters, :color_min, :string
    add_column :rasters, :color_max, :string
    add_column :rasters, :zoom_min, :integer
    add_column :rasters, :zoom_max, :integer
  end
end
