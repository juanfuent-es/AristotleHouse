class StaticController < ApplicationController
  skip_before_action :hold_until_launch, only: :home

  def home
    return render(:coming_soon, layout: "coming_soon") if site.coming_soon
    index
    render :index
  end

  def index
    @projects = Page.projects.published.recent.limit(6)
    @articles = Page.articles.published.recent.limit(3)
  end

  def house
    @page = Page.static.find_by(slug: "house")
  end

  def contact
    @page = Page.static.find_by(slug: "contact")
  end
end
