class Support::AllocationForm
  include ActiveModel::Model

  attr_accessor :device_type, :school
  attr_reader :allocation

  delegate :vcap?,
           :circumstances_devices,
           :over_order_reclaimed_devices,
           :raw_allocation,
           :raw_devices_ordered,
           to: :school

  validate :check_decrease_allowed
  validate :check_minimum

  def allocation=(value)
    @allocation = ActiveModel::Type::Integer.new.cast(value)
  end

  def save
    valid? && allocation_updated?
  end

private

  def allocation_updated?
    UpdateSchoolDevicesService.new(school: school,
                                   "#{device_type}_allocation".to_sym => allocation,
                                   cap_change_category: :allocation_change).call
  end

  def check_decrease_allowed
    errors.add(:school, :decreasing_in_virtual_cap_pool) if decreasing? && vcap?
  end

  def check_minimum
    new_cap = allocation + over_order_reclaimed_devices(device_type) + circumstances_devices(device_type)
    if new_cap < raw_devices_ordered(device_type)
      errors.add(:school, :gte_devices_ordered, devices_ordered: raw_devices_ordered(device_type))
    end
  end

  def decreasing?
    allocation < raw_allocation(device_type)
  end
end
