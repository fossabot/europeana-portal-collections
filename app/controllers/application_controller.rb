##
# Main application controller
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include ControllerExceptionHandling
  include Europeana::Styleguide
  include Catalog
  include DefaultUrlOptions

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  layout proc { kind_of?(Europeana::Styleguide) ? false : 'application' }

  helper Europeana::FeedbackButton::FeedbackHelper

  def current_user
    super || User.new(guest: true)
  end

  private

  def set_locale
    session[:locale] = params[:locale] if params.key?(:locale)
    session[:locale] ||= extract_locale_from_accept_language_header
    session[:locale] ||= I18n.default_locale

    unless I18n.available_locales.map(&:to_s).include?(session[:locale].to_s)
      session.delete(:locale)
      fail ActionController::RoutingError, "Unknown locale #{session[:locale]}"
    end

    I18n.locale = session[:locale]
  end

  def extract_locale_from_accept_language_header
    return unless request.env.key?('HTTP_ACCEPT_LANGUAGE')
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def redirect_to_home
    redirect_to home_url
    return false
  end
end
