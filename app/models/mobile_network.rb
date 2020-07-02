class MobileNetwork < ApplicationRecord
  has_many :extra_mobile_data_requests, dependent: :destroy

  validates :brand, presence: true, uniqueness: true
end
