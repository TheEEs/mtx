require "test_helper"

class I18nTest < ActiveSupport::TestCase
  test "Vietnamese translations for models and attributes" do
    I18n.with_locale(:vi) do
      # Models
      assert_equal "Kênh phát sóng", Room.model_name.human
      assert_equal "Người dùng", User.model_name.human
      assert_equal "Phiên đăng nhập", Session.model_name.human

      # Room attributes
      assert_equal "Tên kênh", Room.human_attribute_name(:name)
      assert_equal "Đơn vị phát sóng", Room.human_attribute_name(:owner)
      assert_equal "Mô tả", Room.human_attribute_name(:description)
      assert_equal "Thời điểm bắt đầu", Room.human_attribute_name(:valid_from)
      assert_equal "Thời điểm kết thúc", Room.human_attribute_name(:valid_to)
      assert_equal "Múi giờ", Room.human_attribute_name(:timezone)
      assert_equal "Mã luồng phát sóng", Room.human_attribute_name(:stream_id)
      assert_equal "Chế độ công khai", Room.human_attribute_name(:is_public)
      assert_equal "Mật khẩu phòng", Room.human_attribute_name(:password)
      assert_equal "Trạng thái khóa", Room.human_attribute_name(:blocked)
      assert_equal "Người tạo", Room.human_attribute_name(:user_id)

      # User attributes
      assert_equal "Địa chỉ email", User.human_attribute_name(:email_address)
      assert_equal "Mật khẩu", User.human_attribute_name(:password)
      assert_equal "Xác nhận mật khẩu", User.human_attribute_name(:password_confirmation)
      assert_equal "Thời điểm xác nhận email", User.human_attribute_name(:confirmed_at)

      # Session attributes
      assert_equal "Địa chỉ IP", Session.human_attribute_name(:ip_address)
      assert_equal "Thiết bị / Trình duyệt", Session.human_attribute_name(:user_agent)
      assert_equal "Người dùng", Session.human_attribute_name(:user_id)
    end
  end
end
