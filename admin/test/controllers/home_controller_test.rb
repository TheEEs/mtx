require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index and display newly created rooms across all users" do
    get root_url
    assert_response :success
    assert_includes response.body, rooms(:one).name
    assert_includes response.body, rooms(:two).name
  end
end
