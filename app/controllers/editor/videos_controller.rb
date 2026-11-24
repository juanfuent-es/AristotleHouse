class Editor::VideosController < Editor::MediaController
  private

  def model = Video

  def file_type = "video/mp4"

  def upload(file) = Media::UploadVideo.call(upload: file)
end
