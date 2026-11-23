class Page < ApplicationRecord
	before_save :set_slug
    # attrs obligatorios
    validates_uniqueness_of :slug
    # validaciones de longitud
    validates :title, length: { maximum: 70 }, presence: true
    validates :og_description, length: { maximum: 200 }
    validates :og_title, length: { maximum: 70 }

    #relations
	has_many :likes, inverse_of: :page
	has_many :visits, inverse_of: :page
	has_many :visitors, through: :visits
	has_many :comments, :as => :commentable, inverse_of: :page
	accepts_nested_attributes_for :visits, allow_destroy: true

    belongs_to :versionable, polymorphic: true, optional: true
    belongs_to :author, class_name: 'User', inverse_of: :pages, optional: true

	# tags
	has_many :taggings, inverse_of: :page
	has_many :tags, through: :taggings

	mount_uploader :og_image, PageUploader

	has_many :blocks, inverse_of: :page, dependent: :destroy
	accepts_nested_attributes_for :blocks, allow_destroy: true, reject_if: proc { |attributes| attributes["content"].blank? }

    def full_url
        return ['', self.lang, self.slug].join("/")
    end

    # views, likes

    def total_views
		views = 0
		self.visits.each { |l| views += l.counter }
		return views
	end

	def total_likes
		counter = 0
		self.likes.each { |l| counter += l.count }
		return counter
	end

	#tagging methods
	def self.tag_counts
		Tag.select("tags.*, count(taggings.tag_id) as count").joins(:taggings).group("taggings.tag_id")
	end

	def self.tagged_with(name)
		Tag.find_by_name!(name).posts
	end

	def tag_list
		tags.map(&:name).join(", ")
	end

	def tag_list=(names)
		self.tags = names.gsub(/\s+/, "").split(",").map do |n|
			Tag.where(name: n.strip).first_or_create!
		end
	end

	def set_slug
		if self.slug.blank?
			_title = ActiveSupport::Inflector.transliterate(og_title.downcase).gsub(/\W+/, "-")
			self.slug = _title.strip.squeeze(' ').gsub(/[^0-9A-Za-z]/, '-')
		end
	end

end