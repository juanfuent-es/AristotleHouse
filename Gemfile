source "https://rubygems.org"

ruby ">= 3.2.0", "< 4.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.4"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use pg as the database for Active Record
gem "pg"
gem "pgcrypto"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
gem "json", "< 3"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"
gem 'devise'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
gem "vite_rails"
# Read more: https://github.com/fnando/browser
gem 'browser'

# Image & Video processors
# file uploader. Read more: https://github.com/carrierwaveuploader/carrierwave
gem 'carrierwave'
# Read more: https://github.com/jtescher/carrierwave-imageoptimizer
gem 'carrierwave-imageoptimizer'
gem 'carrierwave-video'
gem 'carrierwave-video-thumbnailer'
gem 'streamio-ffmpeg'
gem 'mini_magick'
gem 'rmagick', "~> 5.3"

# Catch errors
gem "sentry-ruby"
gem "sentry-rails"

# Optimize html
gem "htmlcompressor"
gem "logger"
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
