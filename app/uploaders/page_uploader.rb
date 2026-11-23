# Page covers. The original also works as the share image.
class PageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/meta-images/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def default_url(*)
    "/brand/share.jpg"
  end

  process resize_to_limit: [2560, 2560]

  version :card do
    process resize_to_limit: [1280, 1280]
  end

  def extension_allowlist
    %w[jpg jpeg gif png webp]
  end
end
