class MobileNetwork < ApplicationRecord
  has_many :recipients
  
  validates :brand, presence: true, uniqueness: true
end
