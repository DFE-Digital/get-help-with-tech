class SchoolVirtualCap < ApplicationRecord
  belongs_to :virtual_cap_pool, touch: true
  belongs_to :school_device_allocation
  delegate :cap, :devices_ordered, to: :virtual_cap_pool
end
