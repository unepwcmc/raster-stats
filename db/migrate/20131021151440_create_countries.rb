class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :iso_a2
      t.text :geometry

      t.timestamps
    end
  end
end
