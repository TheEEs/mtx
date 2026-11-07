class ConfirmationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_confirmation_path, alert: t("flash.rate_limited", default: "Vui lòng thử lại sau.") }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      if user.confirmed?
        redirect_to new_session_path, notice: t("auth.already_confirmed", default: "Tài khoản này đã được xác nhận. Vui lòng đăng nhập.")
        return
      else
        UsersMailer.confirmation(user).deliver_later
      end
    end

    redirect_to new_session_path, notice: t("auth.confirmation_instructions_sent", default: "Nếu tài khoản chưa được xác nhận, hướng dẫn xác nhận đã được gửi vào email của bạn.")
  end

  def show
    user = User.find_by_token_for(:email_confirmation, params[:token])

    if user
      if user.confirmed?
        redirect_to new_session_path, notice: t("auth.already_confirmed", default: "Tài khoản đã được xác nhận trước đó. Vui lòng đăng nhập.")
      else
        user.confirm!
        start_new_session_for user
        redirect_to root_path, notice: t("auth.confirmation_success", default: "Xác nhận email thành công! Chào mừng bạn đã tham gia.")
      end
    else
      redirect_to new_confirmation_path, alert: t("auth.invalid_confirmation_link", default: "Liên kết xác nhận không hợp lệ hoặc đã hết hạn. Vui lòng yêu cầu gửi lại email xác nhận mới.")
    end
  end
end
