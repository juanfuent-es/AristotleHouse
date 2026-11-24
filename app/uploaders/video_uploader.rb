# Private storage. Media::PublishAsset copies the file to the public folder.
class VideoUploader < CarrierWave::Uploader::Base
  storage :file

  def root = Rails.configuration.x.editorial.storage_root

  def store_dir = "videos/#{model.id}"

  def cache_dir = Rails.root.join("tmp/uploads").to_s

  def filename = "#{model.id}.mp4"

  def extension_allowlist = %w[mp4]
end
