class RastersController < ApplicationController
  respond_to :html, :json
  before_filter :authenticate_user!, except: [:index, :show]

  def index
    @rasters = Raster.all
    respond_with(@rasters)
  end

  def show
    @raster = Raster.find(params[:id])
    respond_with(@raster)
  end

  def new
    @raster = Raster.new
    respond_with(@raster)
  end

  def edit
    @raster = Raster.find(params[:id])
    respond_with(@raster)
  end

  def create
    @raster = Raster.new(params[:raster])

    if @raster.save
      flash[:notice] = 'Raster was successfully created.'
    end
    respond_with(@raster)
  end

  def update
    @raster = Raster.find(params[:id])
    if @raster.update_attributes(params[:raster])
      flash[:notice] = 'Raster was successfully updated.'
    end
    @raster.create_tiles
    respond_with(@raster)
  end

  def destroy
    @raster = Raster.find(params[:id])
    @raster.destroy
    flash[:notice] = 'Raster was successfully destroyed.'
    respond_with(@raster)
  end
end
