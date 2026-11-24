# Home as it would be with this draft published.
class Editor::HomePreviewsController < Editor::BaseController
  def show
    page = Page.projects.find(params[:page_id])
    @draft = page.editable_copy
    @projects = Home::FeaturedProjectsQuery.call(preview: @draft)
    @preview = true
    render "static/index"
  end
end
