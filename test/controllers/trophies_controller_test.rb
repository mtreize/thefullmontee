require 'test_helper'

class TrophiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trophy = trophies(:one)
  end

  test "should get index" do
    get trophies_url
    assert_response :success
  end

  test "should get new" do
    get new_trophy_url
    assert_response :success
  end

  test "should create trophy" do
    assert_difference('Trophy.count') do
      post trophies_url, params: { trophy: { description: @trophy.description, name: @trophy.name, technical_name: @trophy.technical_name } }
    end

    assert_redirected_to trophy_url(Trophy.last)
  end

  test "should show trophy" do
    get trophy_url(@trophy)
    assert_response :success
  end

  test "should get edit" do
    get edit_trophy_url(@trophy)
    assert_response :success
  end

  test "should update trophy" do
    patch trophy_url(@trophy), params: { trophy: { description: @trophy.description, name: @trophy.name, technical_name: @trophy.technical_name } }
    assert_redirected_to trophy_url(@trophy)
  end

  test "should destroy trophy" do
    assert_difference('Trophy.count', -1) do
      delete trophy_url(@trophy)
    end

    assert_redirected_to trophies_url
  end
end
