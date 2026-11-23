
class Admin::ImagesController < ApplicationController

  before_action :authenticate_admin!
  before_action :set_image, only: %i[ show edit update destroy ]

  layout "admin"

  # GET /images
  def index
    @images = Image.all
  end

  # GET /images/1
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
    redirect_to admin_image_path(@image)
  end

  # POST /images
  def create
    mime, extension = ""
    if image_params['file'].present?
      mime = image_params['file'].content_type
      extension = mime.split('/')[1]
    end
    @image = Image.create({
      title: image_params['title'],
      alt: image_params['alt'],
      extension: extension,
      mime_type: mime
    })
    @image.file = image_params['file'] if image_params['file'].present?
    if @image.save
      redirect_to admin_image_path(@image), notice: "La imagen ha sido creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /images/1
  def update
    redirect_to admin_image_path(@image)
  end

  # DELETE /images/1
  def destroy
    @image.destroy
    redirect_to admin_images_url, notice: "La imagen ha sido eliminada."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def image_params
      params.require(:image).permit(:title, :file, :alt)
    end
end
