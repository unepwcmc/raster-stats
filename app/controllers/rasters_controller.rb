class RastersController < ApplicationController
  # GET /rasters
  # GET /rasters.json
  def index
    @rasters = Raster.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rasters }
    end
  end

  # GET /rasters/1
  # GET /rasters/1.json
  def show
    @raster = Raster.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @raster }
    end
  end

  # GET /rasters/new
  # GET /rasters/new.json
  def new
    @raster = Raster.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @raster }
    end
  end

  # GET /rasters/1/edit
  def edit
    @raster = Raster.find(params[:id])
  end

  # POST /rasters
  # POST /rasters.json
  def create
    @raster = Raster.new(params[:raster])

    respond_to do |format|
      if @raster.calculate_extra_attributes_and_save
        format.html { redirect_to @raster, notice: 'Raster was successfully created.' }
        format.json { render json: @raster, status: :created, location: @raster }
      else
        format.html { render action: "new" }
        format.json { render json: @raster.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rasters/1
  # PUT /rasters/1.json
  def update
    @raster = Raster.find(params[:id])

    respond_to do |format|
      if @raster.update_attributes(params[:raster])
        format.html { redirect_to @raster, notice: 'Raster was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @raster.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rasters/1
  # DELETE /rasters/1.json
  def destroy
    @raster = Raster.find(params[:id])
    @raster.destroy

    respond_to do |format|
      format.html { redirect_to rasters_url }
      format.json { head :no_content }
    end
  end

  def stats
    render :json => JSON.pretty_generate(Starspan.new({:stat => params[:stat], :raster_id => params[:id], :polygon=>params[:polygon]}).run_analysis)
    #render :json => JSON.pretty_generate(Starspan.new({:operation => params[:operation], :raster_id => params[:id], :polygon=>params[:polygon]}).run_analysis)
  end
end
