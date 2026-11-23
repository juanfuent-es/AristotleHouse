class Admin::BaseController < ApplicationController
  skip_before_action :hold_until_launch
  before_action :authenticate_admin!
  before_action { response.headers["Cache-Control"] = "private, no-store" }

  layout "admin"
end
