class RasterStats < Sinatra::Base

  enable :logging

  get '/' do
    'hello world'
  end

  get '/stats/:raster/:polygon' do
    content_type :json
    begin
      JSON.pretty_generate(Starspan.new({:raster=>params[:raster], :polygon=>params[:polygon]}).run_analysis)
    rescue Exception => e
      return { :error => "There was an error parsing your polygon, make sure that it is in GeoJSON. You provided: #{params[:polygon]} #### #{e.message}" }.to_json
    end
  end

  get '/upload/' do
    haml :upload
  end
  
  post '/upload/form' do
    begin
      CreateRaster.new({:raster_url=>params[:raster_url]}).raster_manager
      return "The file was successfully uploaded!"
    end
  end
  
  #get '/upload/:filename' do
  #  begin
  #    CreateRaster.new({:filename=>params[:filename]}).raster_manager
  #    rescue Exception => e
  #    return { :error => "There was an error importing your file, make sure its name and path are ok"} #### #{e.message}" }.to_json
  #   end
  #end


end
