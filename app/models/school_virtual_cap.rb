class SchoolVirtualCap < ApplicationRecord
  belongs_to :virtual_cap_pool, touch: true
  belongs_to :school_device_allocation
  delegate :allocation, :cap, :devices_ordered, to: :virtual_cap_pool
  # delegate :recalculate_caps!, to: :virtual_cap_pool

  def adjusted_cap
    cap - devices_ordered + school_device_allocation.raw_devices_ordered
  end
end
