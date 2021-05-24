class Support::AllocationForm
  include ActiveModel::Model

  attr_reader :allocation
  attr_accessor :current_allocation, :school_allocation

  delegate :cap, :raw_devices_ordered, :is_in_virtual_cap_pool?, to: :school_allocation

  validate :check_decrease_allowed
  validate :check_minimum

  def initialize(params = {})
    super(params)
    @current_allocation = @school_allocation.dup
  end

  def allocation=(value)
    @allocation = value.to_i
  end

  def order_state
    school_allocation&.school&.order_state
  end

private

  def decreasing?
    allocation < current_allocation.raw_allocation
  end

  def check_decrease_allowed
    return unless decreasing?

    errors.add(:allocation, :decreasing_in_virtual_cap_pool) if is_in_virtual_cap_pool?
  end

  def check_minimum
    if allocation < raw_devices_ordered
      errors.add(:allocation, :gte_devices_ordered, devices_ordered: raw_devices_ordered)
    end
  end
end
