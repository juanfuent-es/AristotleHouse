class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable, :registerable
  devise :database_authenticatable, :rememberable, :validatable

  has_many :pages, foreign_key: :author_id, inverse_of: :author

  def admin?
    role == "admin"
  end

  # Devise: a banned account cannot sign in.
  def active_for_authentication?
    super && !banned?
  end
end
