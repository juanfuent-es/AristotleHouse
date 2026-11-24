require "test_helper"

class ContentTest < ActiveSupport::TestCase
  test "a draft builds its slug and stays private" do
    page = create_draft(title: "First, touch.")
    assert_equal "first-touch", page.slug
    assert_not page.published?
    assert_match(/\Afirst-touch-\h{6}\z/, create_draft(title: "First, touch.").slug)
    assert_match(/\Anew-\h{6}\z/, create_draft(title: "New").slug)
  end

  test "editing a published project changes only its draft until it is published" do
    page = create_published(title: "Original", tag_list: "before", facts: { client: "One" })
    save(page, title: "Changed", tag_list: "after", facts: { client: "Two" }, content: "<h2>New</h2><p>Body</p>")
    assert_equal ["Original", ["before"], "One"], [page.title, page.tags.map(&:name), page.fact("client")]
    assert_equal ["Changed", "after", "Two"], page.editable_copy.then { |copy| [copy.title, copy.tag_list, copy.fact("client")] }
    first_published = page.published_at
    publish(page)
    assert_equal ["Changed", ["after"], "Two", nil], [page.title, page.tags.map(&:name), page.fact("client"), page.draft_content]
    assert_equal first_published, page.published_at
  end

  test "saving one field keeps the rest of the draft" do
    page = create_draft(facts: { client: "One" }, tag_list: "Sound")
    save(page, title: "Only the title")
    copy = page.editable_copy
    assert_equal ["One", "Sound", "<p>Text</p>"], [copy.fact("client"), copy.tag_list, copy.content]
  end

  test "a stale tab never overwrites newer work" do
    page = create_draft
    version = page.lock_version
    save(page, title: "First tab")
    assert_raises(Content::Conflict) { Content::SaveDraft.call(page: page, attributes: { title: "Second" }, expected_version: version) }
    assert_raises(Content::Conflict) { Content::Publish.call(page: page, expected_version: version) }
    assert_equal "First tab", page.reload.editable_copy.title
  end

  test "publishing needs a summary and text under the outline" do
    page = create_draft(description: "", content: Page::OUTLINE)
    error = assert_raises(ActiveRecord::RecordInvalid) { publish(page) }
    assert_equal %i[content description], error.record.errors.attribute_names.sort
    assert_not page.reload.published?
    assert page.draft?
  end

  test "rich text is cleaned and media must come from the library" do
    page = create_published(content: '<h2 onclick="x()">Title</h2><p><a href="javascript:x()">Link</a></p><script>x()</script><img src="https://elsewhere.test/a.png"><p>Text</p>')
    assert_includes page.content, "<h2>Title</h2>"
    assert_no_match(/onclick|javascript:|script|elsewhere/, page.content)
  end

  test "facts only take the four of the template" do
    page = create_draft(facts: { client: "One", admin: "x" })
    assert_equal({ "client" => "One" }, page.draft_content["facts"])
    assert_raises(ActiveRecord::RecordInvalid) { save(page, facts: { client: "x" * 81 }) }
  end

  test "publishing places the files of the cover and the text" do
    image, inside, video = create_image, create_image, create_video
    page = create_draft(cover_image_id: image.id, content: %(<p>Text</p><img data-image-id="#{inside.id}"><video data-video-id="#{video.id}"></video>))
    [image, inside, video].each { |asset| assert_nil asset.reload.published_file }
    publish(page)
    [image, inside, video].each { |asset| assert File.file?(public_file(asset)) }
    assert_includes page.content, inside.published_file
    assert_no_match "/editor/", page.content
    assert_equal [[inside.id], [video.id]], [page.image_ids, page.video_ids]
  end

  test "a missing file stops the publication and keeps the draft" do
    image = create_image
    page = create_draft(content: %(<p>Text</p><img data-image-id="#{image.id}">))
    File.delete(image.file.path)
    assert_raises(Media::Unavailable) { publish(page) }
    assert page.reload.draft?
    assert_not page.published?
  end

  test "home shows featured projects, and a preview swaps in one draft" do
    first = create_published(featured_on_home: "1")
    second = create_published(featured_on_home: "1")
    create_published
    assert_equal [second.id, first.id], Home::FeaturedProjectsQuery.call.map(&:id)
    save(second, featured_on_home: "0")
    assert_equal [second.id, first.id], Home::FeaturedProjectsQuery.call.map(&:id)
    assert_equal [first.id], Home::FeaturedProjectsQuery.call(preview: second.editable_copy).map(&:id)
    Content::Archive.call(page: first, archived: true, expected_version: first.lock_version)
    assert_equal [second.id], Home::FeaturedProjectsQuery.call.map(&:id)
  end

  test "tags are shared whatever their case" do
    create_published(tag_list: "Sound, sound, Retail")
    page = create_published(tag_list: "SOUND")
    assert_equal %w[Retail Sound], Tag.order(:name).pluck(:name)
    assert_equal ["Sound"], page.tags.map(&:name)
  end

  test "the library keeps what is in use and only prunes abandoned uploads" do
    cover, inside, loose = create_image, create_video, create_image
    create_draft(cover_image_id: cover.id, content: %(<video data-video-id="#{inside.id}"></video>))
    [cover, inside, loose].each { |asset| asset.update_columns(created_at: 8.days.ago) }
    assert_not cover.destroy
    assert_not inside.destroy
    assert_equal [loose.id], Media::PruneUploads.call.map { |entry| entry[:id] }
    Media::PruneUploads.call(dry_run: false)
    assert_equal [cover.id], Image.ids
    assert_equal [inside.id], Video.ids
  end

  test "invalid files leave nothing behind" do
    assert_no_difference ["Image.count", "Video.count"] do
      assert_raises(Media::InvalidFile) { Media::UploadImage.call(upload: uploaded("sample.mp4", "image/png")) }
      assert_raises(Media::InvalidFile) { Media::UploadVideo.call(upload: uploaded("cover.png", "video/mp4")) }
      assert_raises(Media::InvalidFile) { Media::UploadImage.call(upload: nil) }
    end
  end
end
