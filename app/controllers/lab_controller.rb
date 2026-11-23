class LabController < ApplicationController

  def index
    @page = Page.find_by_slug("web-lab")
    @experiments = Page.where(category:"web-lab")
    render :layout => 'application'
  end
  
  def show
    @page = Page.find_by_slug(params[:slug])
    # render :layout => 'lab'
  end
  
  def editor
    @page = Page.find_by_slug("web-lab")
    render :layout => 'lab'
  end

end