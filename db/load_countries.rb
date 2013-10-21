#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
require '../config/environment.rb'

json = File.read('./data/world_50m.geojson')
obj = JSON.parse(json)

obj['features'].each do |item| #{|item| pp item['properties']['iso_a2']}

  #pp item['properties']['iso_a2']

  data = {}
  data["iso_a2"] = item['properties']['iso_a2']
  data["geometry"] = item['properties']['geometry']
  
  d = Countries.new(data)
  d.save

end