class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: t("flash.rate_limited", default: "Try again later.") }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      if user.confirmed?
        start_new_session_for user
        redirect_to after_authentication_url
      else
        redirect_to new_confirmation_path(email_address: user.email_address), alert: t("auth.unconfirmed_email_alert", default: "Vui lòng xác nhận email trước khi đăng nhập.")
      end
    else
      redirect_to new_session_path, alert: t("auth.invalid_credentials", default: "Try another email address or password.")
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other
  end
end
