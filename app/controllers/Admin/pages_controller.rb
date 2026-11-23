class Admin::PagesController < Admin::ContentController
  private

  def kind = "static"

  def scope = Page.static
end
