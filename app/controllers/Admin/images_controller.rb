class Admin::ImagesController < Admin::LibraryController
  private

  def model = Image

  def details = %i[title alt]

  def upload(attributes) = Media::UploadImage.call(upload: attributes[:file], title: attributes[:title], alt: attributes[:alt])
end
