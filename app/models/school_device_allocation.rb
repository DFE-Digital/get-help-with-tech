class SchoolDeviceAllocation < ApplicationRecord
  belongs_to  :school
  belongs_to  :created_by_user, class_name: 'User', optional: true
  belongs_to  :last_updated_by_user, class_name: 'User', optional: true

  validate :validate_cap_gte_devices_ordered
  validate :validate_cap_lte_allocation

  enum device_type: {
    'coms_device': 'coms_device',
    'std_device': 'std_device',
  }

  def self.by_device_type(device_type)
    where(device_type: device_type)
  end

  def self.by_computacenter_device_type(cc_device_type)
    by_device_type(Computacenter::CapTypeConverter.to_dfe_type(cc_device_type))
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

  def validate_cap_lte_allocation
    if cap > allocation
      errors.add(:cap, :lte_allocation)
    end
  end

  def validate_cap_gte_devices_ordered
    if cap < devices_ordered
      errors.add(:cap, :gte_devices_ordered)
    end
  end
end
