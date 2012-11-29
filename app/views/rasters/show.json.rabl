object @raster
attributes :id, :display_name
node :tiles_url_format do |r|
  "#{root_url}tiles/#{r.id}/{z}/{x}/{y}.png"
end
