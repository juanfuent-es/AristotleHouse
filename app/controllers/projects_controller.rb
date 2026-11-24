# The collection and each case. Administrators find the tools on these same pages.
class ProjectsController < ApplicationController
  include ContentEditing
  before_action :authenticate_admin!, only: %i[new edit preview]

  def index
    @projects = Page.projects.published.recent.includes(:cover_image)
    return unless admin?
    rest = Page.projects.where.not(id: @projects.map(&:id)).order(updated_at: :desc).includes(:cover_image)
    @drafts, @archived = rest.partition { |project| !project.archived? }
  end

  def show
    @page = Page.projects.published.find_by(slug: params[:slug])
    return redirect_to_draft unless @page
    @content = @page
    @next = following(@page)
  end

  # Opening the page creates nothing.
  def new
    @page = Page.new(category: "project", author: current_user)
    @content = Page.new(category: "project", content: Page::OUTLINE)
    show_editor
  end

  def edit
    @page = find_project or return render_not_found
    @content = @page.editable_copy
    show_editor
  end

  def preview
    @page = find_project or return render_not_found
    @content = @page.editable_copy
    @next = following(@page)
    @private = @preview = true
    render :show
  end

  private

  def find_project
    Page.projects.find_by(slug: params[:slug])
  end

  def redirect_to_draft
    return redirect_to(edit_project_path(params[:slug])) if admin? && find_project
    render_not_found
  end

  # The next one in the list, and back to the first.
  def following(page)
    others = Page.projects.published.recent.to_a
    position = others.index { |other| other.id == page.id }
    candidate = others[position ? (position + 1) % others.size : 0] if others.any?
    candidate unless candidate&.id == page.id
  end
end
