require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index and display only public rooms" do
    get root_url
    assert_response :success
    assert_includes response.body, rooms(:one).name
    assert_includes response.body, rooms(:two).name
    assert_not_includes response.body, rooms(:private_room).name
  end
end
