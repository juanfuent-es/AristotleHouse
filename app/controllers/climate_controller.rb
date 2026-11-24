class ClimateController < ApplicationController
  skip_before_action :hold_until_launch

  # Same answer for everyone, so browsers and proxies can keep it for a minute.
  def show
    expires_in 1.minute, public: true
    render json: params[:at].present? ? Climate.at(params[:at]) : Climate.now
  end
end
