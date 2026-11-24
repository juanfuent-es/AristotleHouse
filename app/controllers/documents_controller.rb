# Editing of the fixed pages: house, contact and the legal texts.
class DocumentsController < ApplicationController
  include ContentEditing
  before_action :authenticate_admin!
  before_action :set_page

  def edit
    @content = @page.editable_copy
    show_editor
  end

  # The page itself, with the draft in place.
  def preview
    @page = @page.editable_copy
    @private = @preview = true
    render %w[house contact].include?(@page.slug) ? "static/#{@page.slug}" : "legals/show"
  end

  private

  def set_page
    @page = Page.static.find_by(slug: params[:slug])
    render_not_found unless @page
  end
end
