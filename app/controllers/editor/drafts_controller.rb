class Editor::DraftsController < Editor::BaseController
  include ContentEditing

  def update
    @page = Page.editorial.find(params[:page_id])
    Content::SaveDraft.call(page: @page, attributes: content_attributes, expected_version: params[:lock_version])
    redirect_to_editor @page.published? ? "Draft saved. Visitors still see the published version." : "Draft saved."
  rescue ActiveRecord::RecordInvalid => error
    @content = error.record
    show_editor(status: :unprocessable_entity)
  rescue Content::Conflict => error
    show_error(error.message, title: "Not saved", conflict: true, typed: Content::SaveDraft.payload(content_attributes))
  end
end
