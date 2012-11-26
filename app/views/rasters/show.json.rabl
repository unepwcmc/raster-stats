object @raster
attributes :id, :display_name
node :tiles_url_format do |r|
  tile_url(r, z: ':z', x: ':x', y: ':y')
end
