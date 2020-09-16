class Support::EnableOrdersForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :order_state, :cap, :device_allocation
  delegate :allocation, :devices_ordered, to: :device_allocation

  validates :order_state, inclusion: { in: School.order_states }
  validates :cap, numericality: { only_integer: true, greater_than: 0 }, if: :cap_required?
  validates_with OrderStateAndCapValidator

  before_validation :override_cap_according_to_order_state!

  def cap_required?
    order_state.to_s == 'can_order_for_specific_circumstances'
  end

  def override_cap_according_to_order_state!
    @cap = device_allocation.cap_implied_by_order_state(order_state: order_state, given_cap: cap)
  end
end
