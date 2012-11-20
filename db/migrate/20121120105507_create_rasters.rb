class CreateRasters < ActiveRecord::Migration
  def change
    create_table :rasters do |t|
      t.string :display_name
      t.string :basename
      t.string :file_name
      t.float :pixel_size
      t.string :input_loc

      t.timestamps
    end
  end
end
