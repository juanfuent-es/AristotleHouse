require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "builds the slug from the title and defaults to English" do
    page = Page.create!(title: "First, touch.", category: "project_draft")
    assert_equal "first-touch", page.slug
    assert_equal "en", page.lang
  end

  test "two pages cannot end up with the same generated slug" do
    Page.create!(title: "Same", category: "project_draft")
    assert_not Page.new(title: "Same", category: "article_draft").save
  end

  test "status moves between draft and published" do
    page = Page.create!(title: "A reading", category: "project_draft")
    page.update!(status: "published", og_description: "What people did.")
    assert_equal "project", page.category
    assert_includes Page.projects.published, page
    page.update!(status: "draft")
    assert_not_includes Page.projects.published, page
  end

  test "publishing needs a summary" do
    page = Page.create!(title: "No summary", category: "article_draft")
    assert_not page.update(status: "published")
  end

  test "static pages cannot become drafts" do
    page = Page.create!(title: "House", category: "static")
    page.update!(status: "draft")
    assert_equal "static", page.category
  end

  test "media blocks must point to the library" do
    page = Page.new(title: "Media", category: "project_draft")
    page.blocks.build(category: "image", content: SecureRandom.uuid)
    assert_not page.valid?
    page = Page.new(title: "Media", category: "project_draft")
    page.blocks.build(category: "image", content: "not-a-uuid")
    assert_not page.valid?
  end
end
