class RasterStats < Sinatra::Base

  get '/' do
    'hello world'
  end

  get '/stats/:polygon' do
    identifier = Time.now.getutc.to_i
    content_type :json
    polygon_file = "polygons/user_polygon_#{identifier}.geojson"
    File.open(polygon_file, 'w'){|f| f.write(params[:polygon])}
    polygon = JSON.parse(params[:polygon])
    Starspan.new({:polygon_file=>polygon_file,:polygon=>polygon, :identifier=>identifier}).stats_results
  end

end
