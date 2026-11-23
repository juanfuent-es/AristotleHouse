class Admin::ArticlesController < Admin::ContentController
  private

  def kind = "article"

  def scope = Page.articles

  def starter_blocks
    [{ category: "text", number: 0 }]
  end
end
