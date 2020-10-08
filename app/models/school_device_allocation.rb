class SchoolDeviceAllocation < ApplicationRecord
  belongs_to  :school
  belongs_to  :created_by_user, class_name: 'User', optional: true
  belongs_to  :last_updated_by_user, class_name: 'User', optional: true

  validates_with CapAndAllocationValidator

  enum device_type: {
    'coms_device': 'coms_device',
    'std_device': 'std_device',
  }

  def self.included_in_performance_analysis
    t = SchoolDeviceAllocation.arel_table
    std_device.where(t[:cap].gt(0).or(t[:allocation].gt(0)))
  end

  def self.can_order_std_devices_now
    by_device_type('std_device').where('cap > devices_ordered')
  end

  def self.by_device_type(device_type)
    where(device_type: device_type)
  end

  def self.by_computacenter_device_type(cc_device_type)
    by_device_type(Computacenter::CapTypeConverter.to_dfe_type(cc_device_type))
  end

  def has_devices_available_to_order?
    available_devices_count.positive?
  end

  def available_devices_count
    cap.to_i - devices_ordered.to_i
  end

  def computacenter_cap_type
    Computacenter::CapTypeConverter.to_computacenter_type(device_type)
  end

  def cap_implied_by_order_state(order_state:, given_cap: nil)
    case order_state.to_sym
    when :cannot_order
      devices_ordered.to_i
    when :can_order
      allocation.to_i
    else # specific circumstances
      given_cap
    end
  end

private

  def cap_lte_allocation
    if cap > allocation
      errors.add(:cap, :lte_allocation, allocation: allocation)
    end
  end
end
