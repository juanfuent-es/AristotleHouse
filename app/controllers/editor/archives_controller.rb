class Editor::ArchivesController < Editor::BaseController
  include ContentEditing

  def update
    @page = Page.projects.find(params[:page_id])
    Content::Archive.call(page: @page, archived: params[:archived] == "1", expected_version: params[:lock_version])
    redirect_to_editor @page.archived? ? "Archived. Visitors no longer see it." : "Restored."
  rescue Content::Conflict => error
    show_error(error.message, title: "Not changed", conflict: true)
  end
end
