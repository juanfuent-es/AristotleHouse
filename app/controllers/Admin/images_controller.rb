class Admin::ImagesController < Admin::BaseController
  before_action :set_image, only: %i[show edit update destroy]

  def index
    @images = Image.order(created_at: :desc)
  end

  def show
  end

  def new
    @image = Image.new
  end

  def edit
    redirect_to admin_image_path(@image)
  end

  def create
    @image = Image.new(image_params.except(:file))
    if (file = image_params[:file])
      @image.mime_type = file.content_type
      # The stored file name is built from slug and extension, so both go first.
      @image.extension = file.content_type.to_s.split("/").last.to_s.sub("jpeg", "jpg")
      @image.set_slug
      @image.file = file
    end
    if @image.save
      redirect_to admin_image_path(@image), notice: "The image was added to the library."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # The file never changes in place: upload another one instead.
  def update
    if @image.update(image_params.slice(:alt))
      redirect_to admin_image_path(@image), notice: "The image was saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    if @image.in_use?
      redirect_to admin_image_path(@image), alert: "This image is used on a page. Remove it there first."
    else
      @image.destroy
      redirect_to admin_images_path, notice: "The image was deleted."
    end
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:title, :file, :alt)
  end
end
