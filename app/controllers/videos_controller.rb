class VideosController < ApplicationController
  skip_before_action :hold_until_launch, only: :sitemap
	before_action :set_base_url
  before_action :set_video, only: :show

  def sitemap
  end

  def show
    render 'show', formats: [:xml], content_type: 'application/dash+xml'
  end

  private 

  def set_video
    @video = Video.find_by_slug(params[:slug])
  end

  def set_base_url
		@base_url = "#{request.protocol}#{request.host_with_port}"
	end

end