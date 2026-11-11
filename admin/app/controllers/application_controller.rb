class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern
  stale_when_importmap_changes

  around_action :switch_locale

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_user
    Current.user
  end
  helper_method :current_user

  private

  def user_not_authorized
    if authenticated?
      flash[:alert] = t("pundit.not_authorized", default: "You are not authorized to perform this action.")
      redirect_back fallback_location: root_path
    else
      flash[:alert] = t("pundit.unauthenticated", default: "Vui lòng đăng nhập để truy cập.")
      request_authentication
    end
  end

  def switch_locale(&action)
    locale = session[:locale] || cookies[:locale] || I18n.default_locale
    locale = locale.to_s.to_sym
    locale = I18n.default_locale unless I18n.available_locales.include?(locale)
    session[:locale] = locale
    I18n.with_locale(locale, &action)
  end
end
