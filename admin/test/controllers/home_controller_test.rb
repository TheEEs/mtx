require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated visitor accessing home#index should not see room list" do
    get root_url
    assert_response :success
    assert_includes response.body, I18n.t("home.empty_title")
    assert_not_includes response.body, rooms(:one).name
    assert_not_includes response.body, rooms(:two).name
    assert_not_includes response.body, rooms(:private_room).name
  end

  test "authenticated user accessing home#index should see created rooms and pinned rooms" do
    user = users(:one)
    created_room = rooms(:one)
    pinned_room = rooms(:two)
    unpinned_other_room = rooms(:private_room_no_password)

    # Pin / Favorite a room
    user.favorites.create!(room: pinned_room)

    sign_in_as(user)
    get root_url
    assert_response :success

    # Displays room created by user
    assert_includes response.body, created_room.name

    # Displays room pinned by user
    assert_includes response.body, pinned_room.name

    # Does not display unpinned rooms of other users
    assert_not_includes response.body, unpinned_other_room.name
  end
end
