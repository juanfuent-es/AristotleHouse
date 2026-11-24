module Content
  # The rich text of a page. Media is always referenced by its id in the library: the
  # address is worked out when it is rendered.
  class Html
    TAGS = %w[p h2 h3 blockquote strong b em i u s a ul ol li br hr img video].freeze
    ATTRIBUTES = %w[href src alt data-image-id data-video-id].freeze
    UUID = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/
    MEDIA = { "image" => "Image", "video" => "Video" }.freeze

    class << self
      def sanitize(html)
        Rails::HTML5::SafeListSanitizer.new.sanitize(html.to_s, tags: TAGS, attributes: ATTRIBUTES)
      end

      def fragment(html)
        doc = Nokogiri::HTML5.fragment(sanitize(html))
        doc.css("img, video").each { |node| node.remove unless reference(node) }
        doc
      end

      # Headings alone are still an outline.
      def meaningful?(html)
        doc = fragment(html)
        return true if doc.css("img, video").any?
        doc.css("h2, h3").remove
        doc.text.gsub(/[ ​\s]/, "").present?
      end

      def references(html)
        doc = fragment(html)
        MEDIA.keys.to_h { |kind| ["#{kind}_ids", doc.css("[data-#{kind}-id]").filter_map { |node| reference(node) }.uniq] }
      end

      def render(html, preview: false, publish: false)
        doc = fragment(html)
        MEDIA.each do |kind, model|
          nodes = doc.css("[data-#{kind}-id]")
          records = model.constantize.where(id: nodes.map { |node| reference(node) }).index_by(&:id)
          nodes.each { |node| place(node, records[reference(node)], preview:, publish:) }
        end
        doc.to_html
      end

      private

      def reference(node)
        id = node[node.name == "img" ? "data-image-id" : "data-video-id"].to_s
        id if UUID.match?(id)
      end

      def place(node, asset, preview:, publish:)
        if publish
          raise Media::Unavailable, "A file in the text is no longer available." unless asset
          Media::PublishAsset.call(asset)
        end
        url = asset && Media::AssetUrl.call(asset, preview: preview)
        return node.remove unless url
        node["src"] = url
        if node.name == "img"
          node["alt"] = node["alt"].presence || asset.alt
          node["width"], node["height"] = asset.width.to_s, asset.height.to_s
          node["loading"] = "lazy"
        else
          node["controls"] = node["playsinline"] = ""
          node["preload"] = "metadata"
        end
      end
    end
  end
end
