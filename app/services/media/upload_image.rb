require "tmpdir"

module Media
  # Every image is turned upright, stripped of its metadata and kept as WebP.
  class UploadImage
    MAX_BYTES = 15.megabytes
    MAX_PIXELS = 40_000_000
    FORMATS = %w[JPEG PNG WEBP].freeze

    def self.call(upload:, title: nil, alt: "")
      unless upload.respond_to?(:tempfile) && upload.size.between?(1, MAX_BYTES)
        raise InvalidFile, "Choose a JPEG, PNG or WebP image of up to 15 MB."
      end
      image = nil
      Dir.mktmpdir("editorial-image-") do |directory|
        source = MiniMagick::Image.open(upload.tempfile.path)
        unless FORMATS.include?(source.type) && source.width.positive? && source.width * source.height <= MAX_PIXELS
          raise InvalidFile, "The image has to be JPEG, PNG or WebP, up to 40 megapixels."
        end
        source.auto_orient
        source.resize "2560x2560>"
        source.strip
        source.format "webp"
        source.quality "85"
        normalized = File.join(directory, "image.webp")
        source.write(normalized)
        id = SecureRandom.uuid
        image = Image.new(id: id, title: UploadTitle.call(Image, upload, title, id), alt: alt.to_s, width: source.width, height: source.height)
        File.open(normalized) do |file|
          image.file = file
          image.save!
        end
      ensure
        source&.destroy!
      end
      image
    rescue MiniMagick::Error, MiniMagick::Invalid, CarrierWave::UploadError => error
      Rails.logger.warn("Image upload: #{error.class}")
      raise InvalidFile, "The image could not be processed. Try another file."
    end
  end
end
