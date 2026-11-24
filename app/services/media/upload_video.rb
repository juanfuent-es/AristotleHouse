module Media
  class UploadVideo
    MAX_BYTES = 100.megabytes

    def self.call(upload:, title: nil)
      unless upload.respond_to?(:tempfile) && upload.size.between?(1, MAX_BYTES)
        raise InvalidFile, "Choose an MP4 video of up to 100 MB."
      end
      movie = FFMPEG::Movie.new(upload.tempfile.path)
      unless movie.valid? && movie.video_codec == "h264" && movie.duration.positive?
        raise InvalidFile, "The file has to be an MP4 with H.264 video."
      end
      id = SecureRandom.uuid
      video = Video.new(id: id, title: UploadTitle.call(Video, upload, title, id), width: movie.width.to_i, height: movie.height.to_i)
      video.file = upload
      video.save!
      video
    rescue FFMPEG::Error, CarrierWave::UploadError => error
      Rails.logger.warn("Video upload: #{error.class}")
      raise InvalidFile, "The video could not be processed."
    end
  end
end
