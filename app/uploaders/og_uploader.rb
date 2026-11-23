class OgUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file
  before :cache, :capture_size

  def store_dir
    "#{model.category.pluralize}/og"
  end

  def filename
    "#{model.id}.#{model.extension}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end
  
  def extension_allowlist
    %w(jpg jpeg gif png mp4 mp3)
  end
  
  private

  # Only once, on the original version. Audio and video have no size to read.
  def capture_size(file)
    return unless version_name.blank? && file.content_type.to_s.start_with?("image/")
    img = ::MiniMagick::Image.read(file.read)
    model.width = img[:width]
    model.height = img[:height]
  end
end
