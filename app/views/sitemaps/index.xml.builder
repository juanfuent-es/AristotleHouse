xml.instruct! :xml, :version=>"1.0"
xml.tag! 'sitemapindex', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.sitemap { xml.loc "#{@base_url}/sitemap-static" }
  xml.sitemap { xml.loc "#{@base_url}/images/sitemap" }
  xml.sitemap { xml.loc "#{@base_url}/videos/sitemap" }
end