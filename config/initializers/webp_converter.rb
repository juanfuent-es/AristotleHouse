# Encodes the current version as WebP with ImageMagick, already required by the
# uploaders. CarrierWave 2's own `manipulate!` does not work with MiniMagick 5.
module WebPConverter
  def convert_to_webp(options = {})
    cache_stored_file! unless cached?
    Tempfile.create(["version", ".webp"]) do |output|
      MiniMagick.convert do |convert|
        convert << current_path
        convert.quality(options.fetch(:quality, 75).to_s)
        convert.define("webp:method=#{options.fetch(:method, 6)}")
        convert << output.path
      end
      FileUtils.cp(output.path, current_path)
    end
  rescue MiniMagick::Error => e
    raise CarrierWave::ProcessingError, e.message
  end
end
