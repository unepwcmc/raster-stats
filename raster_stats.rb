class RasterStats < Sinatra::Base

  enable :logging

  get '/' do
    'hello world'
  end

  get '/stats/:stat/:raster/:polygon' do
    content_type :json
    begin
      JSON.pretty_generate(Starspan.new({:stat=>params[:stat], :raster=>params[:raster], :polygon=>params[:polygon]}).run_analysis)
      #rescue Exception => e
      #return { :error => "There was an error parsing your polygon, make sure that it is in GeoJSON. You provided: #{params[:polygon]} #### #{e.message}" }.to_json
    end
  end

  get '/externalupload/' do
    haml :externalupload
  end
  
  post '/externalupload/form' do
    begin
      CreateRaster.new({:raster_url=>params[:raster_url]}).raster_manager
      return "The file was successfully uploaded!"
    end
  end

  get '/internalupload/' do
    haml :internalupload
  end
  
  post '/internalupload/form' do
    begin
      CreateRaster.new({:raster_loc=>params[:raster_loc]}).raster_manager
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
