class SitemapsController < ApplicationController
  skip_before_action :hold_until_launch
  before_action { @base_url = request.base_url }
  before_action { request.format = :xml }

  def index
  end

  def static
    @pages = site.coming_soon ? [] : Page.editorial.published
  end

  def images
  end
end
