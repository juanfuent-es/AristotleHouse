class ApplicationController < ActionController::Base
  before_action :redirect_nonwww, if: -> { Rails.env.production? }
  before_action :hold_until_launch

  after_action :set_vary_header
  around_action :switch_lang

  helper_method :site, :admin?

  def site
    Rails.configuration.x.site
  end

  def admin?
    user_signed_in? && current_user.admin? && !current_user.banned?
  end

  # Is there an administrator signed in?
  def authenticate_admin!
    return authenticate_user! unless signed_in?
    redirect_to root_path unless admin?
  end

  def switch_lang(&action)
    @lang = I18n.default_locale.to_s
    I18n.with_locale(@lang, &action)
  end

  def render_not_found
    render template: "errors/not_found", status: :not_found, layout: "errors"
  end

  private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || (admin? ? admin_path : root_path)
  end

  # Visitors only reach the holding screen until launch. Controllers that must
  # answer before launch (login, errors, robots...) skip this filter.
  def hold_until_launch
    return if !site.coming_soon || admin? || devise_controller?
    redirect_to root_path
  end

  def redirect_nonwww
    return unless request.host.start_with?("www.")
    redirect_to "#{request.protocol}#{request.host.delete_prefix("www.")}#{request.fullpath}", status: :moved_permanently, allow_other_host: true
  end

  def set_vary_header
    response.headers["Vary"] = "accept" if request.xhr?
  end
end
