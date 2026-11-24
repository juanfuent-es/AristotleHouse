# The library of images and videos. Files never change in place: upload another one.
class Admin::LibraryController < Admin::BaseController
  PER_PAGE = 24
  before_action :set_asset, only: %i[show update destroy]
  helper_method :model

  def index
    @listing = [params[:page].to_i, 1].max
    scope = model.order(created_at: :desc, id: :asc)
    scope = scope.where("title ILIKE ?", "%#{model.sanitize_sql_like(params[:q].to_s.first(100))}%") if params[:q].present?
    assets = scope.limit(PER_PAGE + 1).offset((@listing - 1) * PER_PAGE).to_a
    @more = assets.size > PER_PAGE
    @assets = assets.first(PER_PAGE)
    render "admin/library/index"
  end

  def new
    @asset = model.new
    render "admin/library/new"
  end

  def show
    render "admin/library/show"
  end

  def create
    attributes = params.require(model.model_name.param_key).permit(*details, :file)
    asset = upload(attributes)
    redirect_to [:admin, asset], status: :see_other, notice: "“#{asset.title}” was added to the library."
  rescue Media::InvalidFile, ActiveRecord::RecordInvalid => error
    @asset = model.new(attributes.except(:file))
    @asset.errors.add(:base, error.is_a?(ActiveRecord::RecordInvalid) ? error.record.errors.full_messages.to_sentence : error.message)
    render "admin/library/new", status: :unprocessable_entity
  end

  def update
    if @asset.update(params.require(model.model_name.param_key).permit(*details))
      redirect_to [:admin, @asset], status: :see_other, notice: "Saved."
    else
      render "admin/library/show", status: :unprocessable_entity
    end
  end

  def destroy
    if @asset.destroy
      redirect_to [:admin, model], status: :see_other, notice: "“#{@asset.title}” was deleted."
    else
      redirect_to [:admin, @asset], status: :see_other, alert: @asset.errors.full_messages.to_sentence
    end
  end

  private

  def set_asset
    @asset = model.find(params[:id])
  end
end
