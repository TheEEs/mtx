require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unconfirmed_user = users(:unconfirmed)
    @confirmed_user = users(:one)
  end

  test "new" do
    get new_confirmation_path
    assert_response :success
  end

  test "show with valid token confirms user and logs them in" do
    token = @unconfirmed_user.generate_token_for(:email_confirmation)

    assert_not @unconfirmed_user.confirmed?

    get confirm_email_path(token)

    assert @unconfirmed_user.reload.confirmed?
    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "show with valid token for already confirmed user redirects to login" do
    token = @confirmed_user.generate_token_for(:email_confirmation)

    get confirm_email_path(token)

    assert_redirected_to new_session_path
  end

  test "show with invalid token redirects to new confirmation" do
    get confirm_email_path("invalid-token")

    assert_redirected_to new_confirmation_path
  end

  test "create resends confirmation email for unconfirmed user" do
    assert_enqueued_email_with UsersMailer, :confirmation, args: [ @unconfirmed_user ] do
      post confirmations_path, params: { email_address: @unconfirmed_user.email_address }
    end

    assert_redirected_to new_session_path
  end

  test "create does not resend email for confirmed user but redirects to login" do
    assert_no_emails do
      post confirmations_path, params: { email_address: @confirmed_user.email_address }
    end

    assert_redirected_to new_session_path
  end

  test "create redirects safely for non-existent email" do
    assert_no_emails do
      post confirmations_path, params: { email_address: "nobody@example.com" }
    end

    assert_redirected_to new_session_path
  end
end
