class OperationsController < ApplicationController
  # GET /operations.json
  def index
    @operations = Operation.all
    render json: @operations
  end
  
  def show
    raster = Raster.find(params[:raster_id])
    starspan = Starspan.new(raster, params[:id], params[:polygon])
    starspan.result
  end
end
