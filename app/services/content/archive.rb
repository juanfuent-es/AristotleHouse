module Content
  # Hides a project from visitors and keeps its content.
  class Archive
    def self.call(page:, archived:, expected_version:)
      page.with_lock do
        SaveDraft.check_version!(page, expected_version)
        page.update!(archived_at: archived ? Time.current : nil)
      end
    end
  end
end
