class OperationsController < ApplicationController
  def index
    @operations = Operation.all
    render json: @operations
  end

  def show
    raster = Raster.find(params[:raster_id])
    if params[:iso2]
      polygon = Countries.select(:geometry).where(:iso_a2 => params[:iso2]).first
      starspan = Starspan.new(raster, params[:id], polygon.geometry)
    else
      starspan = Starspan.new(raster, params[:id], params[:polygon])
    end
    render json: starspan.result
  end
end
