class RasterStats < Sinatra::Base

  configure :production, :development do
    enable :logging
  end

  get '/' do
    "
     <h1>Raster Stats</h1>
     <h2>Add a Raster</h2>
     <ul>
      <li><a href='/uploads/external'>from URL</a></li>
      <li><a href='/uploads/internal'>from your computer</a></li>
     </ul>
    "
  end

  get '/stats/:stat/:raster/:polygon' do
    content_type :json
    begin
      JSON.pretty_generate(Starspan.new({:stat=>params[:stat], :raster=>params[:raster], :polygon=>params[:polygon]}).run_analysis)
      #rescue Exception => e
      #return { :error => "There was an error parsing your polygon, make sure that it is in GeoJSON. You provided: #{params[:polygon]} #### #{e.message}" }.to_json
    end
  end

  get '/uploads/external' do
    haml :external_upload
  end

  post '/uploads/external' do
    begin
      Raster.new({:raster_url=>params[:raster_url]}).raster_manager
      return "The file was successfully uploaded!"
    end
  end

  get '/uploads/internal' do
    haml :internal_upload
  end

  post '/uploads/internal' do
    begin
      Raster.new({:raster_loc=>params[:raster_loc]}).raster_manager
      return "The file was successfully uploaded!"
    end
  end

end
