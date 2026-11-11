class LocalesController < ApplicationController
  allow_unauthenticated_access

  def update
    locale = params[:locale].to_s.strip.to_sym
    if I18n.available_locales.include?(locale)
      session[:locale] = locale
      cookies.permanent[:locale] = { value: locale, same_site: :lax }
    end
    redirect_back fallback_location: root_path
  end
end
