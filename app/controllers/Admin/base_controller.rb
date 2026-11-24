class Admin::BaseController < ApplicationController
  skip_before_action :hold_until_launch
  before_action { @private = true }
  before_action :authenticate_admin!

  layout "admin"
end
