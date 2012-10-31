class RasterStats < Sinatra::Base

  get '/' do
    'hello world'
  end

  get '/stats/:polygon' do
    content_type :json

    identifier = Time.now.getutc.to_i
    polygon_file = "polygons/user_polygon_#{identifier}.geojson"
    begin
      File.open(polygon_file, 'w'){|f| f.write(params[:polygon])}
      polygon = JSON.parse(params[:polygon])
    rescue Exception => e
      return { :error => "There was an error parsing your polygon, make sure that it is in GeoJSON. You provided: #{params[:polygon]}" }.to_json
    end
    JSON.pretty_generate(Starspan.new({:polygon_file=>polygon_file,:polygon=>polygon, :identifier=>identifier}).run_analysis)
  end
end
