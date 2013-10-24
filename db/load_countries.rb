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

json = File.read('./data/world_50m.geojson')
obj = JSON.parse(json)
features = obj['features']
Countries.destroy_all
load_features features

json = File.read('./data/world_50m_ru.geojson')
obj = JSON.parse(json)
features = obj['features']
Countries.where(:iso_a2 == "RU").first.destroy
load_features features




