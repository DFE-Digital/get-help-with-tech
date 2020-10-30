class Support::EnableOrdersForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :order_state,
                :device_cap, :device_allocation,
                :router_cap

  attr_writer :router_allocation

  def router_allocation
    @router_allocation || SchoolDeviceAllocation.new
  end

  delegate :devices_ordered, to: :device_allocation

  def routers_ordered
    router_allocation.devices_ordered
  end

  def device_allocation_count
    device_allocation.allocation
  end

  def router_allocation_count
    router_allocation.allocation
  end

  validates :order_state, inclusion: { in: School.order_states }
  validates :device_cap, numericality: { only_integer: true, greater_than: -1 }, if: :cap_required?
  validates :router_cap, numericality: { only_integer: true, greater_than: -1 }, if: :cap_required?

  validate :validate_caps_lte_allocation

  before_validation :override_cap_according_to_order_state!

  def cap_required?
    order_state.to_s == 'can_order_for_specific_circumstances'
  end

  def override_cap_according_to_order_state!
    @device_cap = device_allocation.cap_implied_by_order_state(order_state: order_state, given_cap: device_cap)
    @router_cap = router_allocation.cap_implied_by_order_state(order_state: order_state, given_cap: router_cap)
  end

  def will_enable_orders?
    order_state.to_s.in?(%w[can_order_for_specific_circumstances can_order])
  end

private

  def validate_caps_lte_allocation
    if device_cap.to_i > device_allocation_count.to_i
      errors.add(:device_cap, :lte_allocation, allocation: device_allocation_count.to_i)
    end

    if router_cap.to_i > router_allocation_count.to_i
      errors.add(:router_cap, :lte_allocation, allocation: router_allocation_count.to_i)
    end
  end
end
