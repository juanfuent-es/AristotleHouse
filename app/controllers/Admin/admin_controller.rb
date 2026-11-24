class Admin::AdminController < Admin::BaseController
  def index
    @counts = { "Published" => Page.projects.published.count, "Drafts" => Page.editorial.where.not(draft_content: nil).count,
      "Images" => Image.count, "Videos" => Video.count }
    @recent = Page.editorial.order(updated_at: :desc).limit(8)
  end
end
