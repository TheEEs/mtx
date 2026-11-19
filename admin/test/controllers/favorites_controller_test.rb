require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @room = rooms(:one)
    @other_room = rooms(:two)
  end

  test "unauthenticated user cannot favorite a room" do
    assert_no_difference("Favorite.count") do
      post room_favorite_url(@other_room)
    end
    assert_redirected_to new_session_url
  end

  test "unauthenticated user cannot unfavorite a room" do
    @user.favorites.create!(room: @other_room)
    assert_no_difference("Favorite.count") do
      delete room_favorite_url(@other_room)
    end
    assert_redirected_to new_session_url
  end

  test "authenticated user can favorite a room via HTML" do
    sign_in_as(@user)
    assert_difference("@user.favorites.count", 1) do
      post room_favorite_url(@other_room)
    end
    assert_redirected_to room_url(@other_room)
    assert @user.favorited?(@other_room)
  end

  test "authenticated user can favorite a room via Turbo Stream" do
    sign_in_as(@user)
    assert_difference("@user.favorites.count", 1) do
      post room_favorite_url(@other_room), as: :turbo_stream
    end
    assert_response :success
    assert_match "turbo-stream action=\"replace\"", response.body
    assert_match "unfavorite_room_btn_#{@other_room.hashid}", response.body
  end

  test "authenticated user can unfavorite a room" do
    sign_in_as(@user)
    @user.favorites.create!(room: @other_room)
    assert_difference("@user.favorites.count", -1) do
      delete room_favorite_url(@other_room), as: :turbo_stream
    end
    assert_response :success
    assert_match "favorite_room_btn_#{@other_room.hashid}", response.body
    assert_not @user.favorited?(@other_room)
  end

  test "favorited room appears on rooms#index for user even if owned by someone else" do
    sign_in_as(@user)
    # Before favoriting, other_room is not visible on rooms#index
    get rooms_url
    assert_select "a", text: @other_room.name, count: 0

    # Favorite other_room
    @user.favorites.create!(room: @other_room)

    # Now other_room should appear on rooms#index
    get rooms_url
    assert_select "a", text: @other_room.name, count: 1
  end

  test "favorited room appears on home#index for authenticated user" do
    sign_in_as(@user)
    private_room = rooms(:private_room)
    # Before favoriting, private room does not show on home#index
    get root_url
    assert_not_includes response.body, private_room.name

    # Favorite private room
    @user.favorites.create!(room: private_room)

    get root_url
    assert_includes response.body, private_room.name
  end
end
