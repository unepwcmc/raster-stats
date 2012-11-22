require 'test_helper'

class RastersControllerTest < ActionController::TestCase
  setup do
    @raster = rasters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rasters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create raster" do
    assert_difference('Raster.count') do
      post :create, raster: { display_name: @raster.display_name, pixel_size: @raster.pixel_size, source_file: @raster.source_file }
    end

    assert_redirected_to raster_path(assigns(:raster))
  end

  test "should show raster" do
    get :show, id: @raster
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @raster
    assert_response :success
  end

  test "should update raster" do
    put :update, id: @raster, raster: { display_name: @raster.display_name, pixel_size: @raster.pixel_size, source_file: @raster.source_file }
    assert_redirected_to raster_path(assigns(:raster))
  end

  test "should destroy raster" do
    assert_difference('Raster.count', -1) do
      delete :destroy, id: @raster
    end

    assert_redirected_to rasters_path
  end
end
