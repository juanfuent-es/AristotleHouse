require "test_helper"

class AdminTest < ActionDispatch::IntegrationTest
  setup { sign_in create_admin }

  test "admin is an overview and the library" do
    create_draft
    get admin_path
    assert_response :success
    assert_equal ["/admin", "/projects", "/admin/images", "/admin/videos", "/logout"], css_select("nav[aria-label=Admin] a").map { |link| link["href"] }
    [admin_images_path, new_admin_image_path, admin_videos_path, new_admin_video_path].each do |path|
      get path
      assert_response :success, path
    end
  end

  test "images and videos can be added, described and deleted" do
    { image: "cover.png", video: "sample.mp4" }.each do |kind, name|
      post polymorphic_path([:admin, kind.to_s.pluralize.to_sym]), params: { kind => { title: "My #{kind}", file: file_upload(name, kind == :image ? "image/png" : "video/mp4") } }
      asset = kind.to_s.classify.constantize.find_by!(title: "My #{kind}")
      assert_redirected_to [:admin, asset]
      follow_redirect!
      assert_response :success
      patch polymorphic_path([:admin, asset]), params: { kind => { title: "Renamed #{kind}" } }
      assert_equal "Renamed #{kind}", asset.reload.title
      delete polymorphic_path([:admin, asset])
      assert_not asset.class.exists?(asset.id)
    end
  end

  test "a file in use stays, and a wrong file is explained" do
    image = create_image
    create_draft(cover_image_id: image.id)
    delete admin_image_path(image)
    assert Image.exists?(image.id)
    post admin_images_path, params: { image: { title: "Wrong", file: file_upload("sample.mp4", "video/mp4") } }
    assert_response :unprocessable_entity
    assert_select "input[name='image[title]'][value=Wrong]"
  end
end
