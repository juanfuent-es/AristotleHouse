class Admin::OgsController < ApplicationController

  before_action :authenticate_admin!
  before_action :set_og, only: %i[ show edit update destroy ]

  layout "admin"

  # GET /ogs
  def index
    @ogs = Og.all
  end

  # GET /ogs/1
  def show
  end

  # GET /ogs/new
  def new
    @og = Og.new
  end

  # GET /ogs/1/edit
  def edit
    redirect_to admin_og_path(@og)
  end

  # POST /ogs
  def create
    mime = get_mime(og_params)
    @og = Og.create({
      category: og_params['category'],
      extension: mime.split('/')[1],
      mime_type: mime
    })
    @og.image = og_params['image'] if og_params['image'].present?
    @og.video = og_params['video'] if og_params['video'].present?
    @og.audio = og_params['audio'] if og_params['audio'].present?
    if @og.save
      redirect_to admin_og_path(@og), notice: "Og ha sido creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ogs/1
  def update
    redirect_to admin_og_path(@og)
  end

  # DELETE /ogs/1
  def destroy
    @og.destroy
    redirect_to admin_ogs_url, notice: "Og ha sido eliminado."
  end

  private

    def get_mime(params)
      return params['image'].content_type if params['image'].present?
      return params['video'].content_type if params['video'].present?
      return params['audio'].content_type if params['audio'].present?
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_og
      @og = Og.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def og_params
      params.require(:og).permit(:image, :video, :audio, :category)
    end
end
