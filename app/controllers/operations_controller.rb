class OperationsController < ApplicationController
  # GET /operations.json
  def index
    @operations = Operation.all
    render json: @operations
  end

  # GET /rasters/:raster_id/operations/:id
  def show
    raster = Raster.find(params[:raster_id])
    starspan = Starspan.new(raster, params[:id], params[:polygon])
    render json: starspan.result
  end
end
