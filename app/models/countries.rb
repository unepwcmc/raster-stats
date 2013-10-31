class Countries < ActiveRecord::Base
  attr_accessible :geometry, :iso_a2, :area, :geometry_moll, :area_moll
end
