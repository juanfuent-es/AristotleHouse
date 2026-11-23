class Comment < ApplicationRecord
  # relations
  has_many :comments, as: :commentable
  belongs_to :visitor, inverse_of: :comments
  belongs_to :commentable, polymorphic: true

  #validations
  validates :message, presence: true
end
