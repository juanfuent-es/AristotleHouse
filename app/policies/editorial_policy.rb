class EditorialPolicy
  def initialize(user)
    @user = user
  end

  def manage?
    @user.present? && @user.admin? && !@user.banned?
  end
end
