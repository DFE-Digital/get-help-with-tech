class MobileNetwork < ApplicationRecord
  has_many :recipients, dependent: :destroy

  validates :brand, presence: true, uniqueness: true
end
