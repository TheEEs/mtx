class UsersMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    mail subject: I18n.t("mailers.confirmation.subject", default: "Xác nhận địa chỉ email của bạn"), to: user.email_address
  end
end
