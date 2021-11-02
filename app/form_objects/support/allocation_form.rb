class Support::AllocationForm
  include ActiveModel::Model

  attr_accessor :device_type, :school
  attr_reader :allocation

  delegate :in_virtual_cap_pool?,
           :order_state,
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
                                   order_state: order_state,
                                   "#{device_type}_allocation".to_sym => allocation,
                                   "#{device_type}_cap".to_sym => allocation).call
  end

  def check_decrease_allowed
    errors.add(:school, :decreasing_in_virtual_cap_pool) if decreasing? && in_virtual_cap_pool?
  end

  def check_minimum
    if allocation < raw_devices_ordered(device_type)
      errors.add(:school, :gte_devices_ordered, devices_ordered: raw_devices_ordered(device_type))
    end
  end

  def decreasing?
    allocation < raw_allocation(device_type)
  end
end
