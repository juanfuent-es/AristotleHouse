class LegalsController < ApplicationController
  before_action { @page = Page.static.published.find_by(slug: action_name) }

  def terms = render(:show)

  def privacy = render(:show)

  def cookies = render(:show)
end
