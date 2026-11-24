class ApplicationController < ActionController::Base
  before_action :redirect_nonwww, if: -> { Rails.env.production? }
  before_action :hold_until_launch

  after_action :set_vary_header
  after_action :keep_private
  around_action :switch_lang

  helper_method :site, :admin?, :open?

  def site
    Rails.configuration.x.site
  end

  def admin?
    EditorialPolicy.new(current_user).manage?
  end

  # Can whoever is here browse the site?
  def open?
    !site.coming_soon || admin?
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
    return if open? || devise_controller?
    redirect_to root_path
  end

  def redirect_nonwww
    return unless request.host.start_with?("www.")
    redirect_to "#{request.protocol}#{request.host.delete_prefix("www.")}#{request.fullpath}", status: :moved_permanently, allow_other_host: true
  end

  # Nothing an administrator sees is cached. Drafts never reach a search engine.
  def keep_private
    response.headers["Cache-Control"] = "private, no-store" if @private || admin?
    response.headers["X-Robots-Tag"] = "noindex, nofollow" if @private
  end

  def set_vary_header
    response.headers["Vary"] = "accept" if request.xhr?
  end
end
