class CreateRasters < ActiveRecord::Migration
  def change
    create_table :rasters do |t|
      t.string :display_name
      t.string :source_file
      t.float :pixel_size

      t.timestamps
    end
  end
end
