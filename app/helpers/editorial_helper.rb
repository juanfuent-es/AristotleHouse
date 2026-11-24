module EditorialHelper
  def content_path(page) = Content::Location.path(page)

  def content_edit_path(page) = "#{content_path(page)}/edit"

  def content_preview_path(page) = "#{content_path(page)}/preview"

  # Sanitised when it is saved, and again here.
  def rich_text(content, preview: false)
    tag.div(raw(Content::Html.render(content.content, preview: preview)), class: "rich")
  end

  def cover_url(content, preview: false)
    content.cover_image && Media::AssetUrl.call(content.cover_image, preview: preview)
  end

  def field_error(record, attribute)
    return if record.errors[attribute].empty?
    tag.p(record.errors.full_messages_for(attribute).to_sentence, class: "edit-error", id: "page_#{attribute}_error")
  end

  def field_state(record, attribute)
    record.errors[attribute].any? ? { invalid: true, describedby: "page_#{attribute}_error" } : {}
  end
end
