# A piece of a page. `category` says how to read it (10 characters at most):
#   text    title = heading, content = paragraphs
#   quote   title = who said it, content = the line
#   fact    title = label, content = value (Client, Location, Year...)
#   metric  title = label, content = value
#   image   title = caption, content = id of an Image
#   video   title = caption, content = id of a Video
# css, js, html and glsl belong to the internal sandbox and never render on
# projects or articles.
class Block < ApplicationRecord
  STORY = %w[text quote image video].freeze
  EDITORIAL = %w[text quote image video fact metric].freeze
  SANDBOX = %w[css js html glsl].freeze

  belongs_to :page, inverse_of: :blocks

  validates :category, inclusion: { in: EDITORIAL + SANDBOX }
  validates :title, length: { maximum: 70 }
  validates :title, :content, presence: true, if: -> { %w[fact metric].include?(category) }
  validate :media_exists, if: -> { %w[image video].include?(category) }

  def media
    return unless %w[image video].include?(category)
    (category == "image" ? Image : Video).find_by(id: content)
  end

  private

  def media_exists
    errors.add(:content, :unknown_media) unless media
  end
end
