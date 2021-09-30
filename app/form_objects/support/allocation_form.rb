class Support::AllocationForm
  include ActiveModel::Model

  attr_accessor :category, :description, :device_type, :school
  attr_reader :allocation

  delegate :in_virtual_cap_pool?,
           :laptop_allocation_id,
           :laptop_cap,
           :order_state,
           :router_cap,
           :raw_laptop_allocation,
           :raw_laptops_ordered,
           :raw_router_allocation,
           :raw_routers_ordered,
           :router_allocation_id,
           to: :school

  validate :check_decrease_allowed
  validate :check_minimum

  def allocation=(value)
    @allocation = ActiveModel::Type::Integer.new.cast(value)
  end

  def save
    valid? && allocation_updated?
  end

  def device_allocation_id
    router? ? router_allocation_id : laptop_allocation_id
  end

  def raw_allocation
    router? ? raw_router_allocation : raw_laptop_allocation
  end

  def raw_devices_ordered
    router? ? raw_routers_ordered : raw_laptops_ordered
  end

private

  def allocation_type
    router? ? :router_allocation : :laptop_allocation
  end

  def cap_type
    router? ? :router_cap : :laptop_cap
  end

  def allocation_updated?
    UpdateSchoolDevicesService.new(school: school,
                                   order_state: order_state,
                                   allocation_type => allocation,
                                   cap_type => allocation,
                                   allocation_change_category: category,
                                   allocation_change_description: description).call
  end

  def check_decrease_allowed
    errors.add(:school, :decreasing_in_virtual_cap_pool) if !decreasing? && in_virtual_cap_pool?
  end

  def check_minimum
    if allocation < raw_devices_ordered
      errors.add(:school, :gte_devices_ordered, devices_ordered: raw_devices_ordered)
    end
  end

  def decreasing?
    allocation < raw_allocation
  end

  def router?
    device_type == :router
  end
end
