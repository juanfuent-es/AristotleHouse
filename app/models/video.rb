class Video < ApplicationRecord
  include EditorialAsset

  mount_uploader :file, VideoUploader
end
