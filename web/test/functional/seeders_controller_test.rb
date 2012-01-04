require 'test_helper'

class SeedersControllerTest < ActionController::TestCase
  setup do
    @seeder = seeders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:seeders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create seeder" do
    assert_difference('Seeder.count') do
      post :create, seeder: @seeder.attributes
    end

    assert_redirected_to seeder_path(assigns(:seeder))
  end

  test "should show seeder" do
    get :show, id: @seeder.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @seeder.to_param
    assert_response :success
  end

  test "should update seeder" do
    put :update, id: @seeder.to_param, seeder: @seeder.attributes
    assert_redirected_to seeder_path(assigns(:seeder))
  end

  test "should destroy seeder" do
    assert_difference('Seeder.count', -1) do
      delete :destroy, id: @seeder.to_param
    end

    assert_redirected_to seeders_path
  end
end
