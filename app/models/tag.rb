class Tag < ApplicationRecord
  has_many :taggings, inverse_of: :tag, dependent: :destroy
  has_many :pages, through: :taggings

  validates :name, presence: true, uniqueness: true, length: { maximum: 20 }
end
