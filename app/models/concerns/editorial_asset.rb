# What images and videos of the library share: a file that never changes in place and
# cannot disappear while something uses it.
module EditorialAsset
  extend ActiveSupport::Concern

  included do
    validates :title, presence: true, length: { maximum: 160 }, uniqueness: { case_sensitive: false }
    validates :file, presence: true
    before_update :keep_file
    before_destroy :keep_if_used
  end

  def in_use?
    published_file.present? || Media::References.used?(self)
  end

  def stored?
    file.present? && File.file?(file.path)
  end

  def kind = self.class.name.downcase

  private

  def keep_if_used
    return unless in_use?
    errors.add(:base, "This file is published or used in a page, so it has to stay.")
    throw :abort
  end

  def keep_file
    return unless will_save_change_to_file?
    errors.add(:file, "cannot be replaced. Upload another one.")
    throw :abort
  end
end
