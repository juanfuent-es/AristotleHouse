require "test_helper"

class AdminContentTest < ActionDispatch::IntegrationTest
  test "admin needs an administrator" do
    get admin_projects_path
    assert_redirected_to new_user_session_path
    sign_in User.create!(email: "guest@example.com", password: "secret-123")
    get admin_projects_path
    assert_redirected_to root_path
  end

  test "every admin screen renders" do
    sign_in create_admin
    [admin_path, admin_projects_path, new_admin_project_path, admin_articles_path, new_admin_article_path, admin_pages_path, admin_images_path, new_admin_image_path,
     admin_videos_path, new_admin_video_path, admin_clients_path, new_admin_client_path, admin_ogs_path, new_admin_og_path].each do |path|
      get path
      assert_response :success, path
    end
  end

  test "create, publish, edit blocks and delete a project" do
    sign_in create_admin
    post admin_projects_path, params: { page: { title: "First, touch.", og_description: "A pop-up that learned.", tag_list: "Retail, retail, Sound", status: "draft",
      blocks_attributes: { "0" => { category: "fact", title: "Client", content: "A client", number: 0 }, "1" => { category: "text", title: "Why", content: "Because", number: 1 }, "2" => { category: "fact", title: "Year", content: "", number: 2 } } } }
    page = Page.find_by!(slug: "first-touch")
    assert_redirected_to edit_admin_project_path(page)
    assert_equal "project_draft", page.category
    assert_equal %w[Retail Sound], page.tags.map(&:name).sort
    assert_equal 2, page.blocks.size

    text = page.blocks.find_by(category: "text")
    patch admin_project_path(page), params: { page: { status: "published", blocks_attributes: { "0" => { id: text.id, _destroy: "1" } } } }
    page.reload
    assert page.published?
    assert_equal 1, page.blocks.size

    delete admin_project_path(page)
    assert_redirected_to admin_projects_path
    assert_not Page.exists?(page.id)
  end

  test "a failed save keeps what was typed and the tags as they were" do
    sign_in create_admin
    page = Page.create!(title: "Kept", category: "project_draft", tag_list: "One")
    patch admin_project_path(page), params: { page: { title: "", tag_list: "Two", og_description: "typed" } }
    assert_response :unprocessable_entity
    assert_match "typed", response.body
    assert_equal ["One"], page.reload.tags.map(&:name)
  end

  test "pages of the site keep their url and cannot be deleted" do
    sign_in create_admin
    page = Page.create!(title: "House", category: "static", restricted: true)
    patch admin_page_path(page), params: { page: { slug: "other", content: "New text" } }
    assert_equal ["house", "New text"], page.reload.values_at(:slug, :content)
    delete admin_page_path(page)
    assert Page.exists?(page.id)
  end

  test "a cover can be uploaded" do
    sign_in create_admin
    file = Rack::Test::UploadedFile.new(Rails.public_path.join("android-chrome-192x192.png"), "image/png")
    post admin_projects_path, params: { page: { title: "With cover", og_image: file } }
    page = Page.find_by!(slug: "with-cover")
    assert page.cover?
    assert File.exist?(page.og_image.card.path)
  ensure
    page&.destroy
  end

  test "an image can be added to the library" do
    sign_in create_admin
    file = Rack::Test::UploadedFile.new(Rails.public_path.join("android-chrome-192x192.png"), "image/png")
    post admin_images_path, params: { image: { title: "Test seal upload", alt: "Seal", file: file } }
    image = Image.find_by!(slug: "test-seal-upload")
    assert_redirected_to admin_image_path(image)
    assert File.exist?(image.file.path)
    assert File.exist?(image.file.fhd_webp.path)
    get admin_image_path(image)
    assert_response :success
  ensure
    image&.destroy
  end
end
