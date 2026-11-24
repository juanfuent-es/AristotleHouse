namespace :editorial do
  desc "List uploads unused for more than 7 days. DRY_RUN=0 deletes them."
  task prune_uploads: :environment do
    puts JSON.pretty_generate(Media::PruneUploads.call(dry_run: ENV.fetch("DRY_RUN", "1") != "0"))
  end
end
