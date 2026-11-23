class Image < ApplicationRecord
	before_save :set_slug

	validates :title, length: { maximum: 160 }, uniqueness: { case_sensitive: false }, presence: true
	validates :alt, length: { maximum: 255 }
	mount_uploader :file, ImageUploader

	validate :img_is_present?

	def color
		palette.last || "#FFF"
	end

	def bg
		palette.first || "#00ffd2"
	end

	def palette
		self.extract_palette if self.rainbow.blank? && self.file.present?
		return self.rainbow.split("|")
	end

	def extract_palette
		rainbow = Rainbow.new(self.file.preview.url, 8)
		self.update({ rainbow: rainbow.colors })
	end

	private 

	def img_is_present?
		if self.title.present? && !self.file.present?
			errors.add(:file, "La imagen es requerida")
		end
	end

	def set_slug
		if self.slug.blank?
			_title = ActiveSupport::Inflector.transliterate(title.downcase).gsub(/\W+/, "-")
			self.slug = _title.strip.squeeze(' ').gsub(/[^0-9A-Za-z]/, '-')
		end
	end

end