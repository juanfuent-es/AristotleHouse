class Admin::AdminController < Admin::BaseController
  def index
    @counts = {
      projects: Page.projects.count,
      articles: Page.articles.count,
      drafts: Page.drafts.count,
      images: Image.count
    }
    @recent = Page.where(category: Page::CATEGORIES - ["web-lab"]).order(updated_at: :desc).limit(8)
  end
end
