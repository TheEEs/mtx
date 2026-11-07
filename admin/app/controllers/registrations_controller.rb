class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: t("flash.rate_limited", default: "Vui lòng thử lại sau.") }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      UsersMailer.confirmation(@user).deliver_later
      redirect_to new_session_path, notice: t("auth.registration_success_check_email", default: "Đăng ký thành công! Vui lòng kiểm tra email để xác nhận tài khoản trước khi đăng nhập.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
