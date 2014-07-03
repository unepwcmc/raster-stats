class OperationsController < ApplicationController
  def index
    @operations = Operation.all
    render json: @operations
  end

  def show
    raster = Raster.find(params[:raster_id])
    sats = Statistics.new(raster, params[:id], params[:polygon], false)
    render json: stats.result
  end
end
