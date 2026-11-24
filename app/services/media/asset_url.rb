module Media
  # Editors read the private file. Visitors only get what was published.
  module AssetUrl
    def self.call(asset, preview: false)
      preview ? "/editor/#{asset.kind}s/#{asset.id}/preview" : asset.published_file
    end
  end
end
