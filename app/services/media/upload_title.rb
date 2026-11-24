module Media
  # A readable, unique name in the library, taken from the file when nobody wrote one.
  module UploadTitle
    def self.call(model, upload, title, id)
      return title.squish if title.present?
      label = File.basename(upload.original_filename.to_s, ".*").tr("_-", " ").squish.presence || model.name
      label = label.first(140)
      model.exists?(["lower(title) = ?", label.downcase]) ? "#{label} #{id.first(8)}" : label
    end
  end
end
