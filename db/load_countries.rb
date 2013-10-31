#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
require '../config/environment.rb'


def load_features (features)
  features.each do |item|
    pp item['properties']['iso_a2']
    data = {}
    data["iso_a2"] = item['properties']['iso_a2']
    data["area"] = item['properties']['AREA']
    data["geometry"] = JSON.generate(item['geometry'])
    d = Countries.new(data)
    d.save
  end
end

def update_countries (features)
  features.each do |item|
    country = Countries.where(iso_a2: item['properties']['iso_a2'])[0]
    if country
      Countries.update(country.id, :geometry_moll => JSON.generate(item['geometry']))
    end
  end
end

#json = File.read('./data/world_50m.geojson')
#obj = JSON.parse(json)
#features = obj['features']
#Countries.destroy_all
#load_features features
#
#json = File.read('./data/world_50m_ru.geojson')
#obj = JSON.parse(json)
#features = obj['features']
#Countries.where(:iso_a2 == "RU").first.destroy
#load_features features

json = File.read('./data/world_50m_moll.geojson')
obj = JSON.parse(json)
features = obj['features']
update_countries features

json = File.read('./data/world_50m_ru_moll.geojson')
obj = JSON.parse(json)
features = obj['features']
update_countries features




