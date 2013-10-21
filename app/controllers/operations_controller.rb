class OperationsController < ApplicationController
  def index
    @operations = Operation.all
    render json: @operations
  end

  def show
    raster = Raster.find(params[:raster_id])
    if params[:iso2]
      polygon = Countries.where(:iso_a2 => params[:iso2]).first.geometry
      debugger
      starspan = Starspan.new(raster, params[:id], polygon)
    else
      starspan = Starspan.new(raster, params[:id], params[:polygon])
    end
    render json: starspan.result
  end
end
