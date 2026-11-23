require "test_helper"

class HoldingTest < ActionDispatch::IntegrationTest
  setup do
    Page.create!(title: "Open case", category: "project", og_description: "Public.")
    Page.create!(title: "Hidden case", category: "project_draft")
  end

  test "visitors only reach the holding screen before launch" do
    with_coming_soon(true) do
      get root_path
      assert_response :success
      assert_select "h1", /Coming\s+soon/
      [home_path, projects_path, project_path("open-case"), articles_path, house_path, contact_path, privacy_path].each do |path|
        get path
        assert_redirected_to root_path, path
      end
    end
  end

  test "login, robots, manifest and sitemap answer before launch" do
    with_coming_soon(true) do
      [new_user_session_path, "/robots", "/humans", "/manifest.json", "/sitemap", "/sitemap-static", "/offline"].each do |path|
        get path
        assert_response :success, path
      end
      get "/sitemap-static"
      assert_no_match "open-case", response.body
    end
  end

  test "admins browse the site before launch, drafts included" do
    sign_in create_admin
    with_coming_soon(true) do
      [home_path, projects_path, project_path("open-case"), project_path("hidden-case"), articles_path, house_path, contact_path, privacy_path, cookies_path, terms_path].each do |path|
        get path
        assert_response :success, path
      end
    end
  end

  test "drafts stay private after launch" do
    with_coming_soon(false) do
      get project_path("open-case")
      assert_response :success
      get project_path("hidden-case")
      assert_response :not_found
      get projects_path
      assert_no_match "Hidden case", response.body
    end
  end

  test "content is always escaped" do
    Page.create!(title: "Safe", category: "article", og_description: "x", content: "<script>alert(1)</script>")
    with_coming_soon(false) do
      get article_path("safe")
      assert_no_match "<script>alert(1)", response.body
      assert_match "&lt;script&gt;", response.body
    end
  end
end
