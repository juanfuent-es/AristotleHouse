module Content
  # Where a page lives. Fixed pages keep the URL of the site.
  module Location
    FIXED = %w[house contact privacy cookies terms].freeze

    def self.path(page)
      page.project? ? "/projects/#{page.slug}" : "/#{page.slug}"
    end
  end
end
