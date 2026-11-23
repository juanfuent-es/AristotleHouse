class VideoUploader < CarrierWave::Uploader::Base
  include CarrierWave::Video
  # include CarrierWave::Video::Thumbnailer

  storage :file

  def store_dir
    "videos"
  end

  def extension_allowlist
    %w(mp4)
  end

  version :v_1080 do
    process encode_video: [:mp4, :custom => %w(-c:a copy -crf 22 -speed ultrafast), resolution: "1920×1080"]
    def full_filename (for_file = model.source.file)
      "#{model.slug}.1080p.mp4"
    end
  end

  version :v_720, from_version: :v_1080 do
    process encode_video: [:mp4, :custom => %w(-c:a copy -crf 22 -speed ultrafast), resolution: "1280x720"]
    def full_filename (for_file = model.source.file)
      "#{model.slug}.720p.mp4"
    end
  end
  
  version :v_480, from_version: :v_720 do
    process encode_video: [:mp4, :custom => %w(-c:a copy -crf 22 -speed ultrafast), resolution: "720x480"]
    def full_filename (for_file = model.source.file)
      "#{model.slug}.480p.mp4"
    end
  end
  
  version :v_360, from_version: :v_480 do
    process encode_video: [:mp4, :custom => %w(-c:a copy -crf 22 -speed ultrafast), resolution: "480x360"]
    def full_filename (for_file = model.source.file)
      "#{model.slug}.360p.mp4"
    end
  end

  # version :image do
  #   process thumbnail: [{ format: 'png', quality: 10, size: 192, strip: true, logger: Rails.logger }]
  #   def full_filename for_file
  #     png_name for_file, version_name
  #   end
  # end

  # def png_name for_file, version_name
  #   "#{model.slug}.png"
  # end

end
