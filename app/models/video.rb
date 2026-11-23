class Video < ApplicationRecord
  before_validation :set_slug
  validates :title, length: { maximum: 160 }, uniqueness: { case_sensitive: true }, presence: true

  mount_uploader :file, VideoUploader

  validate :video_is_present?

  def in_use?
    Block.exists?(category: "video", content: id)
  end

  def set_slug
    self.slug = title.to_s.parameterize if slug.blank?
  end

  private

  def video_is_present?
    errors.add(:file, "is required") if title.present? && file.blank?
  end
end
