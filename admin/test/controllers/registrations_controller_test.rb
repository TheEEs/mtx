require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create with valid data creates unconfirmed user and sends confirmation email" do
    assert_difference("User.count", 1) do
      post registration_path, params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    new_user = User.find_by(email_address: "newuser@example.com")
    assert_not_nil new_user
    assert_not new_user.confirmed?

    assert_enqueued_email_with UsersMailer, :confirmation, args: [ new_user ]
    assert_redirected_to new_session_path
  end

  test "create with invalid data renders new with errors" do
    assert_no_difference("User.count") do
      post registration_path, params: {
        user: {
          email_address: "invalid-email",
          password: "short",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
