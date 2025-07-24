require "test_helper"

class NumberGapsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get number_gaps_index_url
    assert_response :success
  end

  test "should get upload" do
    get number_gaps_upload_url
    assert_response :success
  end
end
