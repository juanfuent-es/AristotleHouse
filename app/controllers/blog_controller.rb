class BlogController < ApplicationController
  def index
    @page = Page.where(slug:"blog")
  end

  def show
  end

end