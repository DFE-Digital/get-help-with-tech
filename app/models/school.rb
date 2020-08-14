class School < ApplicationRecord
  belongs_to :responsible_body
  has_many   :device_allocations, class_name: 'SchoolDeviceAllocation'

  validates :urn, presence: true
  validates :name, presence: true

  def allocation_for_type!(device_type)
    device_allocations.find_by_device_type!(device_type)
  end
end
