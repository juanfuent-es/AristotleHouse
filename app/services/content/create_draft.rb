module Content
  class CreateDraft
    def self.call(author:, attributes:)
      data = SaveDraft.payload(attributes)
      data["home_position"] = SaveDraft.next_position if SaveDraft.featured?(data)
      data.merge!(Html.references(data["content"]))
      page = Page.new(category: "project", author: author, title: data["title"], draft_content: data)
      candidate = page.editable_copy
      raise ActiveRecord::RecordInvalid, candidate unless candidate.valid?
      page.save!
      page
    end
  end
end
