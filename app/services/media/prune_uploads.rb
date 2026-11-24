module Media
  # Uploads nobody placed anywhere after a week.
  class PruneUploads
    def self.call(dry_run: true, before: 7.days.ago)
      [Image, Video].flat_map do |model|
        model.where(published_file: nil, created_at: ...before).find_each.filter_map do |asset|
          next if asset.in_use?
          asset.destroy! unless dry_run
          { id: asset.id, type: model.name, action: dry_run ? "would_remove" : "removed" }
        end
      end
    end
  end
end
