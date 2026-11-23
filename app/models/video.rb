class Video < ApplicationRecord
	before_save :set_slug
    validates :title, length: { maximum: 160 }, uniqueness: { case_sensitive: true }, presence: true

    mount_uploader :file, VideoUploader

    validate :video_is_present?
	
    private

    def set_slug
		if self.slug.blank?
			_title = ActiveSupport::Inflector.transliterate(title.downcase).gsub(/\W+/, "-")
			self.slug = _title.strip.squeeze(' ').gsub(/[^0-9A-Za-z]/, '-')
		end
	end

	def video_is_present?
		if self.title.present? && !self.file.present?
			errors.add(:file, "El video es requerido")
		end
	end
    
end