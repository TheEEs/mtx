require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @room = rooms(:one)
    @other_room = rooms(:two)
    sign_in_as(@user)
  end

  test "should get index with only current_user rooms" do
    get rooms_url
    assert_response :success
    assert_select "a", text: @room.name
    assert_select "a", text: @other_room.name, count: 0
  end

  test "should redirect unauthenticated users from index" do
    sign_out
    get rooms_url
    assert_redirected_to new_session_url
  end

  test "should get new" do
    get new_room_url
    assert_response :success
  end

  test "should create room for current_user" do
    assert_difference("Room.count") do
      post rooms_url, params: { room: { description: @room.description, name: "New Channel #{SecureRandom.hex(4)}", owner: @room.owner, valid_from: @room.valid_from, valid_to: @room.valid_to } }
    end

    created_room = Room.last
    assert_equal @user.id, created_room.user_id
    assert_redirected_to room_url(created_room)
  end

  test "should show room with video player when active for owner" do
    @room.update!(valid_from: 1.hour.ago, valid_to: 2.hours.from_now)
    get room_url(@room)
    assert_response :success
    assert_select "video#playing_video", count: 1
  end

  test "should not show another user's room" do
    get room_url(@other_room)
    assert_redirected_to root_url
    assert_equal I18n.t("pundit.not_authorized"), flash[:alert]
  end

  test "should show unavailable notice and no video player when room is expired" do
    @room.update!(valid_from: 2.days.ago, valid_to: 1.day.ago)
    get room_url(@room)
    assert_response :success
    assert_select "video#playing_video", count: 0
    assert_select "h2", text: I18n.t("room_show.unavailable_title")
  end

  test "should show not started notice and no video player when room is not started" do
    @room.update!(valid_from: 1.day.from_now, valid_to: 2.days.from_now)
    get room_url(@room)
    assert_response :success
    assert_select "video#playing_video", count: 0
    assert_select "h2", text: I18n.t("room_show.unavailable_title")
  end

  test "should get edit for owner" do
    get edit_room_url(@room)
    assert_response :success
  end

  test "should not get edit for other user's room" do
    get edit_room_url(@other_room)
    assert_redirected_to root_url
    assert_equal I18n.t("pundit.not_authorized"), flash[:alert]
  end

  test "should update room for owner" do
    patch room_url(@room), params: { room: { description: @room.description, name: @room.name, owner: @room.owner, valid_from: @room.valid_from, valid_to: @room.valid_to } }
    assert_redirected_to room_url(@room)
  end

  test "should not update other user's room" do
    patch room_url(@other_room), params: { room: { name: "Hacked" } }
    assert_redirected_to root_url
    assert_not_equal "Hacked", @other_room.reload.name
    assert_equal I18n.t("pundit.not_authorized"), flash[:alert]
  end

  test "should destroy room for owner" do
    assert_difference("Room.count", -1) do
      delete room_url(@room)
    end

    assert_redirected_to rooms_url
  end

  test "should not destroy other user's room" do
    assert_no_difference("Room.count") do
      delete room_url(@other_room)
    end

    assert_redirected_to root_url
    assert_equal I18n.t("pundit.not_authorized"), flash[:alert]
  end
end
