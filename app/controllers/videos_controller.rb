class VideosController < ApplicationController
  skip_before_action :hold_until_launch

  def sitemap
    @base_url = request.base_url
  end
end
