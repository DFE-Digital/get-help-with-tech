class Support::EnableOrdersForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :order_state,
                :school,
                :laptop_cap,
                :router_cap

  validates :order_state, inclusion: { in: School.order_states }
  validates :laptop_cap, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :cap_required?
  validates :router_cap, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :cap_required?

  validate :validate_caps_lte_allocation

  before_validation :override_cap_according_to_order_state!

  def will_enable_orders?
    order_state.to_s.in?(%w[can_order_for_specific_circumstances can_order])
  end

private

  def cap_required?
    order_state.to_s == 'can_order_for_specific_circumstances'
  end

  def override_cap_according_to_order_state!
    @laptop_cap = @school.laptop_cap_implied_by_order_state(order_state: order_state, given_cap: laptop_cap)
    @router_cap = @school.router_cap_implied_by_order_state(order_state: order_state, given_cap: router_cap)
  end

  def validate_caps_lte_allocation
    if laptop_cap.to_i > school.laptop_allocation
      errors.add(:laptop_cap, :lte_allocation, allocation: school.laptop_allocation)
    end

    if router_cap.to_i > school.router_allocation
      errors.add(:router_cap, :lte_allocation, allocation: school.router_allocation)
    end
  end
end
