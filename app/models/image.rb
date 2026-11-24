class Image < ApplicationRecord
  include EditorialAsset

  mount_uploader :file, ImageUploader
  validates :alt, length: { maximum: 255 }
end
