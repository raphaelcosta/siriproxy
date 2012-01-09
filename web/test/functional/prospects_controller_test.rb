require 'test_helper'

class ProspectsControllerTest < ActionController::TestCase
  setup do
    @prospect = prospects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prospects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create prospect" do
    assert_difference('Prospect.count') do
      post :create, prospect: @prospect.attributes
    end

    assert_redirected_to prospect_path(assigns(:prospect))
  end

  test "should show prospect" do
    get :show, id: @prospect.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @prospect.to_param
    assert_response :success
  end

  test "should update prospect" do
    put :update, id: @prospect.to_param, prospect: @prospect.attributes
    assert_redirected_to prospect_path(assigns(:prospect))
  end

  test "should destroy prospect" do
    assert_difference('Prospect.count', -1) do
      delete :destroy, id: @prospect.to_param
    end

    assert_redirected_to prospects_path
  end
end
