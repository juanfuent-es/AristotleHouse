class ArticlesController < ApplicationController
  def index
    @articles = Page.articles.published.recent.includes(:tags)
  end

  # Admins can open a draft at its final URL to preview it.
  def show
    scope = admin? ? Page.articles : Page.articles.published
    @page = scope.includes(:blocks, :tags, :author).find_by(slug: params[:slug])
    render_not_found unless @page
  end
end
