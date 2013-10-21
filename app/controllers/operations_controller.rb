class OperationsController < ApplicationController
  def index
    @operations = Operation.all
    render json: @operations
  end

  def show
    raster = Raster.find(params[:raster_id])
    if params[:iso2]
      polygon = Countries.find_by :iso_a2 params[:iso2]
    else
      starspan = Starspan.new(raster, params[:id], polygon)
    end
    render json: starspan.result
  end
end
