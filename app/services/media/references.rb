module Media
  class References
    def self.used?(asset)
      key = "#{asset.kind}_ids"
      scope = Page.where("? = ANY(#{key})", asset.id)
      scope = scope.or(Page.where("jsonb_exists(draft_content -> ?, ?)", key, asset.id))
      if asset.is_a?(Image)
        scope = scope.or(Page.where(cover_image_id: asset.id))
        scope = scope.or(Page.where("draft_content ->> 'cover_image_id' = ?", asset.id))
      end
      scope.exists?
    end
  end
end
