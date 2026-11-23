class ErrorsController < ApplicationController
  skip_before_action :hold_until_launch

  # https://guides.rubyonrails.org/v4.2.0/action_controller_overview.html
  layout "errors"

  def not_found
    render status: :not_found
  end

  def unprocessable_entity
    render status: :unprocessable_entity
  end

  def server_error
    render status: :internal_server_error
  end

  def offline
  end

  def image_not_found
    send_file Rails.public_path.join("brand/not-found.png"), type: "image/png", disposition: "inline", status: :not_found
  end
end
