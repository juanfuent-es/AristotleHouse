# Projects and the fixed pages of the site (house, contact, legal texts).
#
# Columns hold what visitors see. `draft_content` holds the edit in progress and only
# reaches the columns through Content::Publish.
class Page < ApplicationRecord
  CATEGORIES = %w[project static web-lab].freeze
  FACTS = %w[client location year scope].freeze
  EDITABLE = %w[title description content cover_image_id facts tag_list featured_on_home home_position].freeze
  RESERVED = %w[new edit preview].freeze
  # A new project opens with this outline.
  OUTLINE = "<h2>The question</h2><p></p><h2>What we built</h2><p></p><h2>What we learned</h2><p></p>".freeze

  belongs_to :author, class_name: "User", optional: true, inverse_of: :pages
  belongs_to :cover_image, class_name: "Image", optional: true
  has_many :taggings, inverse_of: :page, dependent: :destroy
  has_many :tags, through: :taggings

  scope :projects, -> { where(category: "project") }
  scope :static, -> { where(category: "static") }
  scope :editorial, -> { where(category: %w[project static]) }
  scope :published, -> { where(publication_state: "published", archived_at: nil) }
  scope :recent, -> { order(published_at: :desc, id: :asc) }

  before_validation :set_slug, on: :create
  after_save :persist_tags

  validates :category, inclusion: { in: CATEGORIES }
  validates :publication_state, inclusion: { in: %w[draft published] }
  validates :title, presence: true, length: { maximum: 160 }
  validates :description, length: { maximum: 300 }
  validates :slug, presence: true, exclusion: { in: RESERVED }, format: { with: /\A[a-z0-9]+(-[a-z0-9]+)*\z/ }
  validate :slug_is_free
  validate :tags_are_short
  validate :cover_exists
  validate :facts_are_known
  # A draft can be incomplete. What visitors see cannot.
  validates :description, presence: true, on: :publication, if: :project?
  validate :body_is_present, on: :publication, if: :project?

  def project? = category == "project"

  def archived? = archived_at.present?

  def published? = publication_state == "published" && !archived?

  def draft? = draft_content.present?

  # The page as the editor sees it: the published version with the draft on top.
  def editable_copy
    draft = draft_content || {}
    copy = dup
    copy.id = id
    copy.assign_attributes(draft.slice(*EDITABLE))
    copy.tag_list = draft.fetch("tag_list", tag_list)
    copy.lock_version = lock_version
    copy
  end

  def fact(name) = facts.to_h[name].presence

  def tag_list
    @tag_list.nil? ? tags.map(&:name).sort.join(", ") : @tag_list
  end

  def tag_list=(value)
    @tag_list = value.to_s
  end

  def tag_names
    tag_list.split(",").map(&:squish).reject(&:blank?).uniq(&:downcase)
  end

  private

  def set_slug
    return if slug.present?
    base = title.to_s.parameterize.presence || "project"
    taken = RESERVED.include?(base) || self.class.exists?(slug: base)
    self.slug = taken ? "#{base}-#{SecureRandom.hex(3)}" : base
  end

  def slug_is_free
    errors.add(:slug, :taken) if slug.present? && self.class.where(slug: slug).where.not(id: id).exists?
  end

  def tags_are_short
    errors.add(:tag_list, "can have up to 20 characters each") if tag_names.any? { |name| name.length > 20 }
  end

  def cover_exists
    errors.add(:cover_image_id, "is no longer in the library") if cover_image_id_before_type_cast.present? && cover_image.nil?
  end

  def facts_are_known
    valid = facts.is_a?(Hash) && (facts.keys - FACTS).empty? && facts.values.all? { |value| value.to_s.length <= 80 }
    errors.add(:facts, "can have up to 80 characters each") unless valid
  end

  def body_is_present
    errors.add(:content, :blank) unless Content::Html.meaningful?(content)
  end

  def persist_tags
    return if @tag_list.nil?
    names = tag_names
    known = Tag.where("lower(name) IN (?)", names.map(&:downcase)).to_a
    missing = names.reject { |name| known.any? { |tag| tag.name.casecmp?(name) } }
    Tag.insert_all(missing.map { |name| { name: name } }, unique_by: :index_tags_on_name) if missing.any?
    self.tags = known + Tag.where(name: missing)
    @tag_list = nil
  end
end
