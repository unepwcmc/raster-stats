class AddAreaToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :area, :float
    add_index :countries, :area
  end
end
