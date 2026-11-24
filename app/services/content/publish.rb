module Content
  # Moves the saved draft to what visitors see, together with the media it uses.
  class Publish
    def self.call(page:, expected_version:)
      page.with_lock do
        SaveDraft.check_version!(page, expected_version)
        raise Conflict, "Save a draft before publishing." unless page.draft?
        raise Conflict, "Restore the project before publishing." if page.archived?
        candidate = page.editable_copy
        raise ActiveRecord::RecordInvalid, candidate unless candidate.valid?(:publication)
        Media::PublishAsset.call(candidate.cover_image) if candidate.cover_image
        html = Html.render(candidate.content, publish: true)
        page.assign_attributes(page.draft_content.slice(*Page::EDITABLE))
        page.assign_attributes(content: html, **Html.references(html).symbolize_keys,
          publication_state: "published", published_at: page.published_at || Time.current, draft_content: nil)
        page.save!(context: :publication)
      end
      page
    end
  end
end
