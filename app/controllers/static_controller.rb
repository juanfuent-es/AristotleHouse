class StaticController < ApplicationController
  skip_before_action :hold_until_launch, only: :home

  def home
    return render(:coming_soon, layout: "coming_soon") if site.coming_soon
    index
    render :index
  end

  def index
    @projects = Home::FeaturedProjectsQuery.call
  end

  def house
    @page = Page.static.published.find_by(slug: "house")
  end

  def contact
    @page = Page.static.published.find_by(slug: "contact")
  end

  def technology
    @preview_hour = params[:at].presence_in(%w[13:00 23:00])
    @reading = Climate.at(@preview_hour).as_json
  end
end
