class AddGeometryMollToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :geometry_moll, :text
    add_index :countries, :geometry_moll
  end
end
