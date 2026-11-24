# Private storage. Media::PublishAsset copies the file to the public folder.
class ImageUploader < CarrierWave::Uploader::Base
  storage :file

  def root = Rails.configuration.x.editorial.storage_root

  def store_dir = "images/#{model.id}"

  def cache_dir = Rails.root.join("tmp/uploads").to_s

  def filename = "#{model.id}.webp"

  def extension_allowlist = %w[webp]
end
