class Admin::OgsController < Admin::BaseController
  before_action :set_og, only: %i[show edit update destroy]

  def index
    @ogs = Og.all
  end

  def show
  end

  def new
    @og = Og.new
  end

  def edit
    redirect_to admin_og_path(@og)
  end

  def create
    file = og_params[:image] || og_params[:video] || og_params[:audio]
    mime = file&.content_type.to_s
    @og = Og.new(category: og_params[:category], mime_type: mime, extension: mime.split("/").last.to_s)
    # The stored file name is the record id, so the record exists first.
    if @og.save && @og.update(og_params.slice(:image, :video, :audio))
      redirect_to admin_og_path(@og), notice: "The share file was created."
    else
      @og.destroy if @og.persisted?
      render :new, status: :unprocessable_entity
    end
  end

  def update
    redirect_to admin_og_path(@og)
  end

  def destroy
    @og.destroy
    redirect_to admin_ogs_path, notice: "The share file was deleted."
  end

  private

  def set_og
    @og = Og.find(params[:id])
  end

  def og_params
    params.require(:og).permit(:image, :video, :audio, :category)
  end
end
