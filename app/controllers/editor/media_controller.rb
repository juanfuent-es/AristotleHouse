# The library, as the editor's dialog reads it.
class Editor::MediaController < Editor::BaseController
  PER_PAGE = 24

  def index
    page = [params[:page].to_i, 1].max
    scope = model.order(created_at: :desc, id: :asc)
    scope = scope.where("title ILIKE ?", "%#{model.sanitize_sql_like(params[:q].to_s.first(100))}%") if params[:q].present?
    assets = scope.limit(PER_PAGE + 1).offset((page - 1) * PER_PAGE).to_a
    render json: { assets: assets.first(PER_PAGE).map { |asset| serialize(asset) }, next_page: (page + 1 if assets.size > PER_PAGE) }
  end

  def create
    render json: serialize(upload(params.require(:asset).require(:file))), status: :created
  rescue Media::InvalidFile, ActiveRecord::RecordInvalid => error
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def preview
    asset = model.find(params[:id])
    return head(:not_found) unless asset.stored?
    response.headers["X-Content-Type-Options"] = "nosniff"
    send_file asset.file.path, type: file_type, disposition: "inline"
  end

  private

  def serialize(asset)
    { id: asset.id, kind: asset.kind, title: asset.title, alt: asset.try(:alt).to_s, url: Media::AssetUrl.call(asset, preview: true) }
  end
end
