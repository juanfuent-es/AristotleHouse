class Editor::PagesController < Editor::BaseController
  include ContentEditing

  def create
    @page = Content::CreateDraft.call(author: current_user, attributes: content_attributes)
    redirect_to_editor "Draft saved."
  rescue ActiveRecord::RecordInvalid => error
    @page = Page.new(category: "project")
    @content = error.record
    show_editor(status: :unprocessable_entity)
  end
end
