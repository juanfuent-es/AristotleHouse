module Content
  # Saves the edit in progress. Visitors keep seeing the published version.
  class SaveDraft
    class << self
      def call(page:, attributes:, expected_version:)
        page.with_lock do
          check_version!(page, expected_version)
          current = page.editable_copy
          data = snapshot(current).merge(payload(attributes))
          data["home_position"] = next_position if featured?(data) && !current.featured_on_home?
          current.assign_attributes(data.slice(*Page::EDITABLE))
          raise ActiveRecord::RecordInvalid, current unless current.valid?
          page.update!(draft_content: data.merge(Html.references(data["content"])))
        end
      end

      # Only what the editor may write, cleaned.
      def payload(attributes)
        data = attributes.to_h.deep_stringify_keys.slice(*Page::EDITABLE)
        %w[title description].each { |key| data[key] = data[key].to_s.squish if data.key?(key) }
        data["content"] = Html.sanitize(data["content"]) if data.key?("content")
        data["facts"] = data["facts"].to_h.slice(*Page::FACTS).transform_values { |value| value.to_s.squish } if data.key?("facts")
        data["featured_on_home"] = featured?(data) if data.key?("featured_on_home")
        data["cover_image_id"] = data["cover_image_id"].presence if data.key?("cover_image_id")
        data
      end

      def check_version!(page, expected)
        return if expected.to_s.match?(/\A\d+\z/) && page.lock_version == expected.to_i
        raise Conflict, "This page changed in another tab. Copy your changes and reload the saved version."
      end

      def featured?(data) = ActiveModel::Type::Boolean.new.cast(data["featured_on_home"]) || false

      def next_position = Page.projects.maximum(:home_position).to_i + 1

      private

      def snapshot(page) = Page::EDITABLE.index_with { |name| page.public_send(name) }
    end
  end
end
