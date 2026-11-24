class Admin::VideosController < Admin::LibraryController
  private

  def model = Video

  def details = %i[title]

  def upload(attributes) = Media::UploadVideo.call(upload: attributes[:file], title: attributes[:title])
end
