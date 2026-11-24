class Editor::PublicationsController < Editor::BaseController
  include ContentEditing

  def create
    @page = Page.editorial.find(params[:page_id])
    Content::Publish.call(page: @page, expected_version: params[:lock_version])
    redirect_to Content::Location.path(@page), status: :see_other, notice: "Published."
  rescue ActiveRecord::RecordInvalid => error
    @error_title = "Not published yet"
    @content = error.record
    @page.reload
    show_editor(status: :unprocessable_entity)
  rescue Content::Conflict => error
    show_error(error.message, title: "Not published", conflict: true)
  rescue Media::Unavailable => error
    show_error(error.message, title: "Not published")
  rescue SystemCallError => error
    Rails.logger.error("Publication: #{error.class} #{error.message}")
    show_error("A file could not be prepared. The draft is safe.", title: "Not published")
  end
end
