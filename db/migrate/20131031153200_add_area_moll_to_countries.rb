class AddAreaMollToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :area_moll, :float
    add_index :countries, :area_moll
  end
end
