require "test_helper"

class EditorTest < ActionDispatch::IntegrationTest
  test "visitors see published projects without tools" do
    create_draft(title: "Hidden case")
    page = create_published(title: "Open case", facts: { client: "A client" })
    with_coming_soon(false) do
      get projects_path
      assert_select "h3", "Open case"
      assert_no_match "Hidden case", response.body
      assert_select "a[href=?]", new_project_path, count: 0
      get project_path(page.slug)
      assert_select "h1", "Open case"
      assert_select ".case__facts dd", "A client"
      assert_select "[data-controller=content-editor]", count: 0
      get project_path("hidden-case")
      assert_response :not_found
    end
  end

  test "every editing step needs an active administrator" do
    page = create_draft
    image = create_image
    reads = [new_project_path, edit_project_path(page.slug), preview_project_path(page.slug), editor_images_path, preview_editor_image_path(image), editor_home_preview_path(page), admin_path, admin_images_path]
    create_static("house")
    reads << edit_document_path("house")
    attempt = lambda do |expected|
      reads.each { |path| get path; assert_redirected_to expected, path }
      post editor_pages_path, params: { page: { title: "x" } }
      assert_redirected_to expected
      patch editor_page_draft_path(page), params: { lock_version: page.lock_version, page: { title: "x" } }
      assert_redirected_to expected
      post editor_page_publication_path(page), params: { lock_version: page.lock_version }
      assert_redirected_to expected
      patch editor_page_archive_path(page), params: { lock_version: page.lock_version, archived: "1" }
      assert_redirected_to expected
      post editor_images_path, params: { asset: { file: file_upload("cover.png", "image/png") } }
      assert_redirected_to expected
    end
    with_coming_soon(false) do
      attempt.call(new_user_session_path)
      sign_in create_admin(role: "visitor")
      attempt.call(root_path)
    end
    assert_equal [page.lock_version, false], page.reload.then { |p| [p.lock_version, p.published?] }
    assert_equal 1, Image.count
  end

  test "create, edit in place, preview, publish and archive a project" do
    sign_in create_admin
    assert_no_difference("Page.count") { get new_project_path }
    assert_select "textarea[name='page[title]']"
    assert_select "textarea[name='page[content]']", /The question/
    assert_select "input[name^='page[facts]']", count: 4

    post editor_pages_path, params: { page: { title: "A reading", description: "What people did.", content: "<p>Body</p>", tag_list: "Sound", facts: { client: "A client" }, publication_state: "published", category: "static" } }
    page = Page.find_by!(slug: "a-reading")
    assert_redirected_to edit_project_path("a-reading")
    assert_equal ["project", "draft"], [page.category, page.publication_state]

    get preview_project_path("a-reading")
    assert_select "h1", "A reading"
    assert_select ".case__facts dd", "A client"
    assert_select "span.tag", "Sound"
    assert_equal ["private, no-store", "noindex, nofollow"], response.headers.values_at("Cache-Control", "X-Robots-Tag")

    post editor_page_publication_path(page), params: { lock_version: page.lock_version }
    assert_redirected_to project_path("a-reading")
    get edit_project_path("a-reading")
    assert_response :success

    page.reload
    patch editor_page_archive_path(page), params: { lock_version: page.lock_version, archived: "1" }
    sign_out :user
    with_coming_soon(false) do
      get project_path("a-reading")
      assert_response :not_found
    end
  end

  test "errors keep what was typed" do
    sign_in create_admin
    post editor_pages_path, params: { page: { title: "", description: "Keep this" } }
    assert_response :unprocessable_entity
    assert_select "textarea[name='page[description]']", /Keep this/

    page = create_draft
    version = page.lock_version
    save(page, title: "Other tab")
    patch editor_page_draft_path(page), params: { lock_version: version, page: { title: "My change", facts: { client: "Mine" } } }
    assert_response :conflict
    assert_select "textarea[name='page[title]']", /My change/
    assert_select "input[name='page[facts][client]'][value=Mine]"
    assert_equal "Other tab", page.reload.editable_copy.title

    empty = create_draft(content: Page::OUTLINE)
    post editor_page_publication_path(empty), params: { lock_version: empty.lock_version }
    assert_response :unprocessable_entity
    assert_select "#page_content_error"
  end

  test "opening a draft at its address takes administrators to the editor" do
    page = create_draft
    sign_in create_admin
    get project_path(page.slug)
    assert_redirected_to edit_project_path(page.slug)
    get project_path("nothing-here")
    assert_response :not_found
  end

  test "the library uploads, searches and serves private files" do
    sign_in create_admin
    post editor_images_path, params: { asset: { file: file_upload("cover.png", "image/png") } }
    assert_response :created
    url = response.parsed_body.fetch("url")
    get url
    assert_equal "image/webp", response.media_type
    post editor_videos_path, params: { asset: { file: file_upload("sample.mp4", "video/mp4") } }
    assert_response :created
    get response.parsed_body.fetch("url")
    assert_equal "video/mp4", response.media_type
    post editor_images_path, params: { asset: { file: file_upload("sample.mp4", "video/mp4") } }
    assert_response :unprocessable_entity
    Image.first.update!(title: "Light 100%")
    get editor_images_path(q: "%")
    assert_equal 1, response.parsed_body["assets"].size
    get editor_images_path(q: "_")
    assert_empty response.parsed_body["assets"]
  end

  test "the home preview shows the draft and home does not" do
    page = create_draft(title: "Soon at home", featured_on_home: "1")
    sign_in create_admin
    get editor_home_preview_path(page)
    assert_select "a[href=?]", preview_project_path(page.slug)
    get home_path
    assert_no_match "Soon at home", response.body
  end

  test "fixed pages are edited at their own address" do
    page = create_static("house", description: "He was an observer.")
    create_static("privacy")
    sign_in create_admin
    %w[house privacy].each do |slug|
      get edit_document_path(slug)
      assert_response :success, slug
      get preview_document_path(slug)
      assert_response :success, slug
    end
    patch editor_page_draft_path(page), params: { lock_version: page.lock_version, page: { title: "House", description: "A new line.", content: "<p>New body</p>" } }
    assert_redirected_to "/house/edit"
    get house_path
    assert_match "He was an observer.", response.body
    page.reload
    post editor_page_publication_path(page), params: { lock_version: page.lock_version }
    assert_redirected_to house_path
    follow_redirect!
    assert_select "h1", "A new line."
    assert_select ".rich p", "New body"
  end

  test "saving keeps its protection against forged requests" do
    page = create_draft
    sign_in create_admin
    before = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    patch editor_page_draft_path(page), params: { lock_version: page.lock_version, page: { title: "Forged" } }
    assert_response :unprocessable_entity
    assert_not_equal "Forged", page.reload.editable_copy.title
  ensure
    ActionController::Base.allow_forgery_protection = before
  end
end
