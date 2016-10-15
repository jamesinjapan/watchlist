require 'test_helper'

class RecommendationControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
