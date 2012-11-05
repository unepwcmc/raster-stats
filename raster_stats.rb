class RasterStats < Sinatra::Base

  enable :logging

  get '/' do
    'hello world'
  end

  get '/stats/:polygon' do
    content_type :json
    begin
      JSON.pretty_generate(Starspan.new({:polygon=>params[:polygon]}).run_analysis)
    rescue Exception => e
      return { :error => "There was an error parsing your polygon, make sure that it is in GeoJSON. You provided: #{params[:polygon]} #### #{e.message}" }.to_json
    end
  end
end
