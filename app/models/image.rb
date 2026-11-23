class Image < ApplicationRecord
  before_validation :set_slug

  validates :title, length: { maximum: 160 }, uniqueness: { case_sensitive: false }, presence: true
  validates :alt, length: { maximum: 255 }
  mount_uploader :file, ImageUploader

  validate :img_is_present?

  def color
    palette.last || "#FFF"
  end

  def bg
    palette.first || "#0B0A0F"
  end

  def palette
    extract_palette if rainbow.blank? && file.present?
    rainbow.to_s.split("|")
  end

  def extract_palette
    update(rainbow: Rainbow.new(file.preview.url, 8).colors)
  end

  def in_use?
    Block.exists?(category: "image", content: id)
  end

  def set_slug
    self.slug = title.to_s.parameterize if slug.blank?
  end

  private

  def img_is_present?
    errors.add(:file, "is required") if title.present? && file.blank?
  end
end
