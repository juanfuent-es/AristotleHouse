class Editor::ImagesController < Editor::MediaController
  private

  def model = Image

  def file_type = "image/webp"

  def upload(file) = Media::UploadImage.call(upload: file)
end
