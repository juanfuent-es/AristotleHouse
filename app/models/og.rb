class Og < ApplicationRecord

    validates_presence_of :category, :mime_type

    mount_uploader :audio, OgUploader
    mount_uploader :video, OgUploader
    mount_uploader :image, OgUploader

end