class School < ApplicationRecord
  belongs_to :responsible_body
  has_many   :school_device_allocations
  
  validates :urn, presence: true
  validates :name, presence: true
end
