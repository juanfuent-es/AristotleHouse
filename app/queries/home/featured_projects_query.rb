module Home
  # Published projects chosen for home. A preview swaps in one draft and leaves the rest.
  class FeaturedProjectsQuery
    LIMIT = 6

    def self.call(preview: nil)
      scope = Page.published.projects.where(featured_on_home: true)
      scope = scope.where.not(id: preview.id) if preview
      pages = scope.includes(:cover_image).order(home_position: :desc, id: :asc).limit(LIMIT).to_a
      pages << preview if preview&.featured_on_home? && !preview.archived?
      pages.sort_by { |page| [-page.home_position, page.id.to_s] }.first(LIMIT)
    end
  end
end
