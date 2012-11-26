class TilesController < ApplicationController
  def show
    @raster = Raster.find(params[:raster_id])
    @raster.create_tile(params[:z], params[:x], params[:y])
    send_file "#{Rails.root.join('public', 'tiles', params[:raster_id], params[:z], params[:x])}/#{params[:y]}.png", :type => 'image/png', :disposition => 'inline'
  end
end
