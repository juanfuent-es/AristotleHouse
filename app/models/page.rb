# Projects (Work), articles (Thinking) and static pages share this table.
# The editorial state lives in `category`: "project" is published, "project_draft"
# is not. Static pages are always published.
class Page < ApplicationRecord
  KINDS = %w[project article static].freeze
  DRAFT_SUFFIX = "_draft".freeze
  STATUSES = %w[draft published].freeze

  attribute :lang, default: "en"

  before_validation :set_defaults
  before_validation :set_slug

  validates :title, length: { maximum: 70 }, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]+(-[a-z0-9]+)*\z/, message: "can only use lowercase letters, numbers and hyphens" }
  validates :og_title, length: { maximum: 70 }
  validates :og_description, length: { maximum: 200 }
  validates :category, inclusion: { in: ->(_) { CATEGORIES } }
  # A draft can be incomplete. What visitors see cannot.
  validates :og_description, presence: true, if: -> { published? && kind != "static" }

  CATEGORIES = %w[project project_draft article article_draft static web-lab].freeze

  #relations
  has_many :likes, inverse_of: :page
  has_many :visits, inverse_of: :page
  has_many :visitors, through: :visits
  has_many :comments, as: :commentable, inverse_of: :commentable
  accepts_nested_attributes_for :visits, allow_destroy: true

  belongs_to :versionable, polymorphic: true, optional: true
  belongs_to :author, class_name: "User", inverse_of: :pages, optional: true

  # tags
  has_many :taggings, inverse_of: :page, dependent: :destroy
  has_many :tags, through: :taggings

  mount_uploader :og_image, PageUploader

  has_many :blocks, -> { order(:number) }, inverse_of: :page, dependent: :destroy
  accepts_nested_attributes_for :blocks, allow_destroy: true, reject_if: proc { |attributes| attributes["id"].blank? && attributes["content"].blank? }

  scope :projects, -> { where(category: %w[project project_draft]) }
  scope :articles, -> { where(category: %w[article article_draft]) }
  scope :static, -> { where(category: "static") }
  scope :published, -> { where(category: KINDS) }
  scope :drafts, -> { where(category: %w[project_draft article_draft]) }
  scope :recent, -> { order(created_at: :desc) }

  def kind
    category.to_s.delete_suffix(DRAFT_SUFFIX)
  end

  def published?
    KINDS.include?(category)
  end

  def status
    published? ? "published" : "draft"
  end

  def status=(value)
    return unless STATUSES.include?(value.to_s) && kind != "static"
    self.category = value.to_s == "draft" ? "#{kind}#{DRAFT_SUFFIX}" : kind
  end

  def public_path
    case kind
    when "project" then "/work/#{slug}"
    when "article" then "/thinking/#{slug}"
    else "/#{slug}"
    end
  end

  def cover?
    self[:og_image].present?
  end

  # Grouped blocks. Reads from the loaded association so lists do not query per row.
  def blocks_of(*categories)
    blocks.select { |block| categories.include?(block.category) }
  end

  def facts = blocks_of("fact")

  def metrics = blocks_of("metric")

  def story = blocks_of(*Block::STORY)

  def fact(label)
    facts.find { |block| block.title.casecmp?(label) }&.content
  end

  # views, likes

  def total_views
    visits.sum(&:counter)
  end

  def total_likes
    likes.sum(&:count)
  end

  #tagging methods
  def tag_list
    tags.map(&:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.to_s.split(",").map(&:strip).reject(&:blank?).uniq(&:downcase).map do |name|
      Tag.where("lower(name) = ?", name.downcase).first || Tag.create!(name: name.first(20))
    end
  end

  private

  def set_defaults
    self.og_title = title.to_s if og_title.blank?
  end

  def set_slug
    self.slug = (slug.presence || og_title.presence || title).to_s.parameterize if slug.blank? || slug_changed?
  end
end
