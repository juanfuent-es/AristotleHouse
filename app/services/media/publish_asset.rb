require "fileutils"
require "tempfile"

module Media
  class PublishAsset
    def self.call(asset)
      raise Unavailable, "The chosen file is no longer available." unless asset.stored?
      asset.with_lock do
        relative = asset.published_file.presence || "/media/#{asset.kind}s/#{asset.file.identifier}"
        copy(asset.file.path, Rails.configuration.x.editorial.public_root.join(relative.delete_prefix("/")))
        asset.update!(published_file: relative) unless asset.published_file == relative
      end
    end

    # Written aside and renamed, so a half-copied file is never served.
    def self.copy(source, destination)
      return if File.file?(destination)
      FileUtils.mkdir_p(destination.dirname)
      temporary = "#{destination}.#{SecureRandom.hex(4)}.tmp"
      FileUtils.copy_file(source, temporary)
      File.chmod(0o644, temporary)
      File.rename(temporary, destination)
    ensure
      FileUtils.rm_f(temporary) if temporary
    end
    private_class_method :copy
  end
end
