class OperationsController < ApplicationController
  def index
    @operations = Operation.all
    render json: @operations
  end

  def show
    raster = Raster.find(params[:raster_id])
    starspan = Starspan.new(raster, params[:id], params[:polygon])
    render json: starspan.result
  end
end
