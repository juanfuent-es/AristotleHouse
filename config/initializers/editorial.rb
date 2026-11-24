# Where the media library lives. Uploads are private; publishing copies them to the
# public folder. Tests use their own folders.
root = Rails.env.test? ? Rails.root.join("tmp/editorial-test") : Rails.root
Rails.application.config.x.editorial = ActiveSupport::OrderedOptions.new.merge!(
  storage_root: Pathname.new(ENV["EDITORIAL_STORAGE_ROOT"].presence || root.join("storage/editorial")).to_s,
  public_root: root.join("public")
)
