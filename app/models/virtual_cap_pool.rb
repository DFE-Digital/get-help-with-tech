class VirtualCapPool < ApplicationRecord
  belongs_to :responsible_body
  has_many :school_virtual_caps, dependent: :destroy
  has_many :school_device_allocations, through: :school_virtual_caps
  has_many :schools, through: :school_device_allocations

  after_touch :recalculate_caps!

  enum device_type: {
    'coms_device': 'coms_device',
    'std_device': 'std_device',
  }

  def recalculate_caps!
    self.cap = school_device_allocations.sum(:cap)
    self.devices_ordered = school_device_allocations.sum(:devices_ordered)
    save!
    # TODO: trigger events for CC here?
  end

  def add_school!(school)
    if school_can_be_added_to_pool?(school)
      add_school_allocation(school.device_allocations.find_by(device_type: device_type))
    else
      raise VirtualCapPoolError, "Cannot add school to virtual pool #{school.urn} #{school.name}"
    end
  end

private

  def school_can_be_added_to_pool?(school)
    school.responsible_body_id == responsible_body_id &&
      (school.can_order? || school.can_order_for_specific_circumstances?) &&
      school.device_allocations.exists?(device_type: device_type) &&
      !school_virtual_caps.exists?(school_device_allocation: school.device_allocations.find_by(device_type: device_type))
  end

  def add_school_allocation(allocation)
    transaction do
      school_virtual_caps.create!(school_device_allocation: allocation)
      update_caps!(cap_change: allocation.raw_cap, devices_ordered_change: allocation.raw_devices_ordered)
    end
  end

  def update_caps!(cap_change: 0, devices_ordered_change: 0)
    update!(cap: cap + cap_change, devices_ordered: devices_ordered + devices_ordered_change)
    # TODO: trigger events for CC here?
  end
end
