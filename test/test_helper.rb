ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "fileutils"

class ActiveSupport::TestCase
  teardown { FileUtils.rm_rf(Rails.root.join("tmp/editorial-test")) }

  def create_admin(**attributes)
    User.create!({ email: "#{SecureRandom.hex(6)}@example.com", password: "secret-123", role: "admin" }.merge(attributes))
  end

  def create_draft(**attributes)
    Content::CreateDraft.call(author: create_admin, attributes: { title: "Case #{SecureRandom.hex(4)}", description: "A summary.", content: "<p>Text</p>" }.merge(attributes))
  end

  def create_published(**attributes) = publish(create_draft(**attributes))

  def publish(page)
    Content::Publish.call(page: page, expected_version: page.lock_version).reload
  end

  def save(page, **attributes)
    Content::SaveDraft.call(page: page, attributes: attributes, expected_version: page.lock_version)
    page.reload
  end

  def create_static(slug, **attributes)
    Page.create!({ slug: slug, title: slug.capitalize, category: "static", publication_state: "published", published_at: Time.current }.merge(attributes))
  end

  def file_upload(name, type)
    Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files", name), type)
  end

  def create_image = Media::UploadImage.call(upload: uploaded("cover.png", "image/png"))

  def create_video = Media::UploadVideo.call(upload: uploaded("sample.mp4", "video/mp4"))

  def uploaded(name, type)
    ActionDispatch::Http::UploadedFile.new(tempfile: file_upload(name, type).tempfile, filename: name, type: type)
  end

  def public_file(asset) = Rails.configuration.x.editorial.public_root.join(asset.reload.published_file.delete_prefix("/"))
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def with_coming_soon(value)
    site = Rails.configuration.x.site
    before = site.coming_soon
    site.coming_soon = value
    yield
  ensure
    site.coming_soon = before
  end
end
