class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::ImageOptimizer
  include WebPConverter

  storage :file

  def store_dir
    "images"
  end

  def filename
    "#{model.slug}.#{model.extension}"
  end

  def extension_allowlist
    %w(webp jpeg gif png)
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # Quad HighDefinition
  version :quad_hd do
    process resize_to_fit: [2560, 2560] #2560x1440
    process optimize: [{ quality: 80 }]
  end
  # Full HD
  version :fhd, from_version: :quad_hd do
    process resize_to_fit: [1920, 1920] #1920x1080p
  end
  #High Definition
  version :hd, from_version: :fhd do
    process resize_to_fit: [1280, 1280] #1280x720
  end
  # Quarter of HD
  version :qhd, from_version: :hd do #960X540
    process resize_to_fit: [960, 960]
  end
  # Video Graphics Array - (SD Standar Definition)
  version :vga, from_version: :qhd do #640x480
    process resize_to_fit: [640, 640]
  end
  
  # webp versions
  version :quad_hd_webp, from_version: :quad_hd do
    process convert_to_webp: [{ quality: 75, method: 6 }]
    def full_filename (for_file = model.source.file)
      "#{model.slug}.2560.webp"
    end
  end
  
  version :fhd_webp, from_version: :fhd do
    process convert_to_webp: [{ quality: 75, method: 6 }]
    def full_filename (for_file = model.source.file)
      "#{model.slug}.1920.webp"
    end
  end

  version :hd_webp, from_version: :hd do
    process convert_to_webp: [{ quality: 75, method: 6 }]
    def full_filename (for_file = model.source.file)
      "#{model.slug}.1280.webp"
    end
  end
  
  version :qhd_webp, from_version: :qhd do
    process convert_to_webp: [{ quality: 75, method: 6 }]
    def full_filename (for_file = model.source.file)
      "#{model.slug}.960.webp"
    end
  end

  version :vga_webp, from_version: :vga do
    process convert_to_webp: [{ quality: 75, method: 6 }]
    def full_filename (for_file = model.source.file)
      "#{model.slug}.640.webp"
    end
  end
  
  # Preview for color calculations, histogram obtains palette
  version :preview, from_version: :vga do
    process resize_to_fill: [320, 320]
  end
  
  # thumbnail 
  version :thumb do
    process resize_to_fill: [240, 240]
  end
  
  protected

  def fix_exif_rotation
    manipulate! do |image|
      image = image.auto_orient!
    end
  end

end