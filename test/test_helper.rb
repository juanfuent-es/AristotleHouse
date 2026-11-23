ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  def create_admin
    User.create!(email: "editor@example.com", password: "secret-123", role: "admin", name: "Editor", username: "editor")
  end
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
