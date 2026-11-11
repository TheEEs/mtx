require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @room = rooms(:one)
    @other_room = rooms(:two)
    @private_room = rooms(:private_room)
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

  test "should create room for current_user with is_public setting" do
    assert_difference("Room.count") do
      post rooms_url, params: {
        room: {
          description: @room.description,
          name: "New Channel #{SecureRandom.hex(4)}",
          owner: @room.owner,
          valid_from: @room.valid_from,
          valid_to: @room.valid_to,
          is_public: false,
          password: "mysecretpassword"
        }
      }
    end

    created_room = Room.last
    assert_equal @user.id, created_room.user_id
    assert_equal false, created_room.is_public
    assert created_room.password_protected?
    assert created_room.authenticate("mysecretpassword")
    assert_redirected_to room_url(created_room)
  end

  test "should create private room without password when password is omitted" do
    assert_difference("Room.count") do
      post rooms_url, params: {
        room: {
          description: @room.description,
          name: "Private No Pass Channel #{SecureRandom.hex(4)}",
          owner: @room.owner,
          valid_from: @room.valid_from,
          valid_to: @room.valid_to,
          is_public: false
        }
      }
    end

    created_room = Room.last
    assert_equal @user.id, created_room.user_id
    assert_equal false, created_room.is_public
    assert_nil created_room.password_digest
    assert_not created_room.password_protected?
    assert_redirected_to room_url(created_room)
  end

  test "should allow registered user to view private room directly when room has no password" do
    private_no_pass = rooms(:private_room_no_password)
    private_no_pass.update!(valid_from: 1.hour.ago, valid_to: 2.hours.from_now)
    get room_url(private_no_pass)
    assert_response :success
    assert_select "video#playing_video", count: 1
    assert_select "input#password", count: 0
  end

  test "should allow unauthenticated visitor to view public room" do
    sign_out
    get room_url(@room)
    assert_response :success
  end

  test "should redirect unauthenticated visitor from private room to login" do
    sign_out
    get room_url(@private_room)
    assert_redirected_to new_session_url
    assert_equal I18n.t("pundit.unauthenticated"), flash[:alert]
  end

  test "should prompt non-owner registered user for password when accessing private room" do
    @private_room.update!(valid_from: 1.hour.ago, valid_to: 2.hours.from_now)
    # First access renders unlock form
    get room_url(@private_room)
    assert_response :success
    assert_select "input#password", count: 1
    assert_select "video#playing_video", count: 0

    # Wrong password renders unprocessable_entity
    post unlock_room_url(@private_room), params: { password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_equal I18n.t("rooms.invalid_password"), flash[:alert]

    # Correct password unlocks and redirects to room
    post unlock_room_url(@private_room), params: { password: "secret123" }
    assert_redirected_to room_url(@private_room)
    assert_equal I18n.t("rooms.unlock_success"), flash[:notice]

    # Following redirect now displays the video player
    follow_redirect!
    assert_response :success
    assert_select "video#playing_video", count: 1
  end

  test "should allow owner to view private room directly without entering password" do
    @private_room.update!(valid_from: 1.hour.ago, valid_to: 2.hours.from_now)
    sign_in_as(users(:two)) # Owner of @private_room
    get room_url(@private_room)
    assert_response :success
    assert_select "video#playing_video", count: 1
    assert_select "input#password", count: 0
  end

  test "should show room with video player when active for owner" do
    @room.update!(valid_from: 1.hour.ago, valid_to: 2.hours.from_now)
    get room_url(@room)
    assert_response :success
    assert_select "video#playing_video", count: 1
    # Owner should see toggle stream button and WHIP config box
    assert_select "#toggle_stream_#{@room.hashid}_1", count: 1
    assert_select "h2", text: I18n.t("room_show.whip_title"), count: 1
    assert_select "button[data-controller='share']", count: 1
    assert_select "#share_room_#{@room.hashid}", count: 1
    # Owner should see screen share controls and modal
    assert_select "#screen_share_btn", count: 1
    assert_select "dialog[data-screen-share-target='modal']", count: 1
    assert_select "select[data-screen-share-target='videoCodecSelect']", count: 1
    assert_select "select[data-screen-share-target='audioCodecSelect']", count: 1
    assert_select "div[data-screen-share-target='unsupportedView']", count: 1
  end

  test "should not show toggle stream button or whip config box to non-owner" do
    @other_room.update!(valid_from: 1.hour.ago, valid_to: 2.hours.from_now)
    get room_url(@other_room)
    assert_response :success
    # Non-owner should NOT see toggle stream button or WHIP config box, but CAN see share button
    assert_select "#toggle_stream_#{@other_room.hashid}_1", count: 0
    assert_select "h2", text: I18n.t("room_show.whip_title"), count: 0
    assert_select "button[data-controller='share']", count: 1
    assert_select "#screen_share_btn", count: 0
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
    patch room_url(@room), params: { room: { description: @room.description, name: @room.name, owner: @room.owner, valid_from: @room.valid_from, valid_to: @room.valid_to, is_public: false, password: "newpassword123" } }
    assert_redirected_to room_url(@room)
    assert_equal false, @room.reload.is_public
    assert @room.authenticate("newpassword123")
  end

  test "should update room to private without password" do
    patch room_url(@room), params: { room: { is_public: false } }
    assert_redirected_to room_url(@room)
    assert_equal false, @room.reload.is_public
    assert_nil @room.password_digest
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

  test "should authenticate mediamtx auth request with custom internal host header" do
    post rooms_auth_url,
      params: { path: @room.hashid, token: @room.jwt, id: "stream-session-123" },
      headers: { "Host" => "admin-web-72355eaddfbaefb06618512e9b4318dad40b2b17" }
    assert_response :success
    assert_equal "OK", response.body
    assert_equal "stream-session-123", @room.reload.stream_id
  end

  test "should reject mediamtx auth request with invalid token" do
    post rooms_auth_url,
      params: { path: @room.hashid, token: "invalid-token", id: "stream-session-123" },
      headers: { "Host" => "admin-web-72355eaddfbaefb06618512e9b4318dad40b2b17" }
    assert_response :unauthorized
    assert_equal "Error", response.body
  end
end
