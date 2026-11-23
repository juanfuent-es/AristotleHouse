xml.instruct! :xml, version: "1.0"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url { xml.loc "#{@base_url}/" }
  @pages.each do |page|
    xml.url do
      xml.loc "#{@base_url}#{page.public_path}"
      xml.lastmod page.updated_at.iso8601
    end
  end
end
