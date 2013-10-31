class OperationsController < ApplicationController
  def index
    @operations = Operation.all
    render json: @operations
  end

  def show
    raster = Raster.find(params[:raster_id])
    if params[:iso2]
      country = Countries.where(:iso_a2 => params[:iso2]).first
      if params[:moll] == 'true'
        polygon = country.geometry_moll
      else
        polygon = country.geometry
      end
      area = country.area
      area_moll = country.area_moll
      geo_json = "{\"type\": \"FeatureCollection\",\"features\": [{\"type\": \"Feature\", \"id\": 0, \"properties\": { \"AREA_MOLL\": #{area_moll}, \"AREA\": #{area} },\"geometry\": #{polygon}}]}"
      starspan = Starspan.new(raster, params[:id], geo_json, true)
    else
      starspan = Starspan.new(raster, params[:id], params[:polygon], false)
    end
    render json: starspan.result
  end
end
