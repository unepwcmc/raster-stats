class RasterStats < Sinatra::Base

  get '/' do
    'hello world'
  end

  get '/stats/:polygon' do
    identifier = Time.now.getutc.to_i
    content_type :json
    polygon_file = "polygons/user_polygon_#{identifier}.geojson"
    File.open(polygon_file, 'w'){|f| f.write(params[:polygon])}
    begin
      polygon = JSON.parse(params[:polygon])
    rescue Exception => e
      return { :error => "There was an error parsing your polygon, make sure that it is in GeoJSON. You provided: #{params[:polygon]}" }.to_json
    end
    Starspan.new({:polygon_file=>polygon_file,:polygon=>polygon, :identifier=>identifier}).run_analysis
  end

end
