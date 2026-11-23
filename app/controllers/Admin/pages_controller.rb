class Admin::PagesController < ApplicationController

  before_action :authenticate_admin!
  before_action :set_page, only: %i[ show edit update destroy ]

  layout "admin"

  def index
    @pages = Page.all
  end

  def show
    redirect_to admin_pages_url
  end

  def new
    @page = Page.new
  end

  def edit
  end

  def create
    @page = Page.new(page_params)

    if @page.save
      redirect_to admin_page_url(@page), notice: "La página #{@page.title} ha sido creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @page.update(page_params)
      redirect_to admin_pages_url, notice: "La página #{@page.title} ha sido actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @page.restricted
      redirect_to admin_pages_url, notice: "Página restringida. #{@page.title} no se puede eliminar."
    else
      @page.destroy
      redirect_to admin_pages_url, notice: "La página #{@page.title} ha sido eliminada."
    end
  end

  private
    def set_page
      @page = Page.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:slug, :lang, :title, :description, :category, :content, :restricted, :metatag, :versionable_id, metatag_attributes: [:_id])
    end
end