class OperationsController < ApplicationController
  def index
    @operations = Operation.all
    render json: @operations
  end

  def show
    raster = Raster.find(params[:raster_id])
    if params[:iso2]
      country = Countries.where(:iso_a2 => params[:iso2]).first
      if params[:moll]
        polygon = country.geometry_moll
      else
	polygon = country.geometry
      end
      area = country.area
      geo_json = "{\"type\": \"FeatureCollection\",\"features\": [{\"type\": \"Feature\", \"id\": 0, \"properties\": { \"id\": null, \"AREA\": #{area} },\"geometry\": #{polygon}}]}"
      starspan = Starspan.new(raster, params[:id], geo_json)
    else
      starspan = Starspan.new(raster, params[:id], params[:polygon])
    end
    
    render json: starspan.result
  end
end
