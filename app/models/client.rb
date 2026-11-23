class Client < ApplicationRecord
  belongs_to :country

  validates :name, presence: true
end
