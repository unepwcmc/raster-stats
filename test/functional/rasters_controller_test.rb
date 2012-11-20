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
      post :create, raster: { display_name: @raster.display_name, file_name: @raster.file_name, high_res_path: @raster.high_res_path, input_loc: @raster.input_loc, input_url: @raster.input_url, low_res_path: @raster.low_res_path, low_res_value: @raster.low_res_value, medium_res_path: @raster.medium_res_path, medium_res_value: @raster.medium_res_value, pixel_size: @raster.pixel_size }
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
    put :update, id: @raster, raster: { display_name: @raster.display_name, file_name: @raster.file_name, high_res_path: @raster.high_res_path, input_loc: @raster.input_loc, input_url: @raster.input_url, low_res_path: @raster.low_res_path, low_res_value: @raster.low_res_value, medium_res_path: @raster.medium_res_path, medium_res_value: @raster.medium_res_value, pixel_size: @raster.pixel_size }
    assert_redirected_to raster_path(assigns(:raster))
  end

  test "should destroy raster" do
    assert_difference('Raster.count', -1) do
      delete :destroy, id: @raster
    end

    assert_redirected_to rasters_path
  end
end
