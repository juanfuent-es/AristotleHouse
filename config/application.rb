require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AristotleHouse
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # catch server errors (404, 500, 422)
    config.exceptions_app = self.routes
    # CUSTOM GENERATOR
    # @see: https://guides.rubyonrails.org/generators.html
    config.generators do |g|
      g.scaffold_stylesheet false
      g.orm             :active_record
      g.template_engine :erb
      g.test_framework  :test_unit, fixture: false
      g.stylesheets     false
    end

    config.time_zone = "Abu Dhabi"

    config.i18n.available_locales = [:en]
    config.i18n.default_locale = :en
  end
end
