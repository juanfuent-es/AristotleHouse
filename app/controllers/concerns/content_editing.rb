# What every step of the editor shares: how a page is shown, read and explained when
# something goes wrong.
module ContentEditing
  extend ActiveSupport::Concern

  private

  def content_attributes
    params.require(:page).permit(:title, :description, :content, :cover_image_id, :tag_list, :featured_on_home, facts: Page::FACTS).to_h
  end

  def show_editor(status: :ok)
    @private = @editing = true
    render "editor/pages/edit", status: status
  end

  # The fields keep what was typed.
  def show_error(message, title:, conflict: false, typed: nil)
    @content = @page.reload.editable_copy
    @content.assign_attributes(typed) if typed
    @content.errors.add(:base, message)
    @error_title = title
    @conflict = conflict
    show_editor(status: conflict ? :conflict : :unprocessable_entity)
  end

  def redirect_to_editor(notice)
    redirect_to "#{Content::Location.path(@page)}/edit", status: :see_other, notice: notice
  end
end
