class ProjectsController < ApplicationController
  def index
    @projects = Page.projects.published.recent.includes(:tags, :blocks)
  end

  # Admins can open a draft at its final URL to preview it.
  def show
    scope = admin? ? Page.projects : Page.projects.published
    @page = scope.includes(:blocks, :tags).find_by(slug: params[:slug])
    return render_not_found unless @page
    @next = Page.projects.published.recent.where.not(id: @page.id).first
  end
end
