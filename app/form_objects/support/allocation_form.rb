class Support::AllocationForm
  include ActiveModel::Model

  attr_accessor :allocation, :device_type, :school

  delegate :in_virtual_cap_pool?, :order_state,
           :raw_laptop_allocation, :raw_router_allocation,
           :raw_laptop_cap, :raw_router_cap,
           :raw_laptops_ordered, :raw_routers_ordered,
           to: :school

  validate :check_decrease_allowed
  validate :check_minimum

  def save
    valid? && allocation_updated?
  end

  private

  def allocation_type
    router? ? :router_allocation : :laptop_allocation
  end

  def cap
    router? ? raw_router_cap : raw_laptop_cap
  end

  def cap_type
    router? ? :router_cap : :laptop_cap
  end

  def allocation_updated?
    UpdateSchoolDevicesService.new(school: school,
                                   order_state: order_state,
                                   allocation_type => allocation,
                                   cap_type => cap).call
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

  def raw_allocation
    router? ? raw_router_allocation : raw_laptop_allocation
  end

  def raw_devices_ordered
    router? ? raw_routers_ordered : raw_laptops_ordered
  end

  def router?
    device_type == :router
  end
end
