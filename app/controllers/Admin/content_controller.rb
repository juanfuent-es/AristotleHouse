# Shared CRUD for everything stored in Page. Subclasses declare their kind.
class Admin::ContentController < Admin::BaseController
  before_action :set_page, only: %i[edit update destroy]
  before_action :load_library, only: %i[new edit create update]
  helper_method :kind, :collection_path, :member_path

  def index
    @pages = scope.includes(:tags).order(updated_at: :desc)
    render "admin/content/index"
  end

  def new
    @page = Page.new(category: initial_category)
    starter_blocks.each { |attributes| @page.blocks.build(attributes) }
    render "admin/content/form"
  end

  def edit
    render "admin/content/form"
  end

  def create
    @page = Page.new(category: initial_category, author: current_user)
    if save_page
      redirect_to url_for(action: :edit, id: @page.id), notice: "“#{@page.title}” was created."
    else
      render "admin/content/form", status: :unprocessable_entity
    end
  end

  def update
    if save_page
      redirect_to url_for(action: :edit, id: @page.id), notice: "“#{@page.title}” was saved."
    else
      render "admin/content/form", status: :unprocessable_entity
    end
  end

  def destroy
    if @page.restricted
      redirect_to collection_path, alert: "“#{@page.title}” is part of the site and cannot be deleted."
    else
      @page.destroy
      redirect_to collection_path, notice: "“#{@page.title}” was deleted."
    end
  end

  private

  def collection_path
    url_for(action: :index, only_path: true)
  end

  def member_path(page)
    page.persisted? ? url_for(action: :update, id: page.id, only_path: true) : collection_path
  end

  # Static pages have no draft state.
  def initial_category
    kind == "static" ? "static" : "#{kind}#{Page::DRAFT_SUFFIX}"
  end

  def starter_blocks
    []
  end

  def load_library
    @images = Image.order(created_at: :desc)
    @videos = Video.order(created_at: :desc)
    @clients = Client.order(:name)
  end

  def set_page
    @page = scope.includes(:blocks, :tags).find(params[:id])
  end

  # Tags are written by assignment, so the whole save is one transaction.
  def save_page
    saved = false
    Page.transaction do
      @page.assign_attributes(page_params)
      saved = @page.save
      raise ActiveRecord::Rollback unless saved
    end
    saved
  end

  def page_params
    permitted = %i[title og_title og_description keywords content tag_list og_image remove_og_image og_image_cache status]
    permitted << :slug unless @page&.restricted
    params.require(:page).permit(*permitted, blocks_attributes: %i[id category title content number _destroy])
  end
end
