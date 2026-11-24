xml.instruct! :xml, version: "1.0"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url { xml.loc "#{@base_url}/" }
  [projects_path, technology_path].each { |path| xml.url { xml.loc "#{@base_url}#{path}" } } unless site.coming_soon
  @pages.each do |page|
    xml.url do
      xml.loc "#{@base_url}#{Content::Location.path(page)}"
      xml.lastmod page.updated_at.iso8601
    end
  end
end
