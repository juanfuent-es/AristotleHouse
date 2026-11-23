class Admin::VideosController < Admin::BaseController
  before_action :set_video, only: %i[show edit update destroy]

  def index
    @videos = Video.order(created_at: :desc)
  end

  def show
  end

  def new
    @video = Video.new
  end

  def edit
    redirect_to admin_video_path(@video)
  end

  def create
    @video = Video.new(title: video_params[:title])
    @video.set_slug
    @video.file = video_params[:file] if video_params[:file].present?
    if @video.save
      redirect_to admin_video_path(@video), notice: "The video was added to the library."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    redirect_to admin_video_path(@video)
  end

  def destroy
    if @video.in_use?
      redirect_to admin_video_path(@video), alert: "This video is used on a page. Remove it there first."
    else
      @video.destroy
      redirect_to admin_videos_path, notice: "The video was deleted."
    end
  end

  private

  def set_video
    @video = Video.find(params[:id])
  end

  def video_params
    params.require(:video).permit(:file, :title)
  end
end
