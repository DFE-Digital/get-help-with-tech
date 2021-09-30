class Support::EnableOrdersForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :order_state,
                :school
  attr_reader   :laptop_cap,
                :router_cap

  validates :order_state, inclusion: { in: School.order_states.keys }
  validates :laptop_cap, presence: true, if: :cap_required?
  validates :laptop_cap, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }
  validates :router_cap, presence: true, if: :cap_required?
  validates :router_cap, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }

  validate :validate_caps_lte_allocation

  before_validation :override_cap_according_to_order_state!

  def laptop_cap=(value)
    @laptop_cap = ActiveModel::Type::Integer.new.cast(value)
  end

  def router_cap=(value)
    @router_cap = ActiveModel::Type::Integer.new.cast(value)
  end

  def save(validate: true)
    (!validate || valid?) && orders_enabled?
  end

  def will_enable_orders?
    order_state.to_s.in?(%w[can_order_for_specific_circumstances can_order])
  end

private

  def cap_required?
    order_state.to_s == 'can_order_for_specific_circumstances'
  end

  def orders_enabled?
    UpdateSchoolDevicesService.new(school: school,
                                   order_state: order_state,
                                   laptop_cap: laptop_cap,
                                   router_cap: router_cap).call
  end

  def override_cap_according_to_order_state!
    @laptop_cap = school.adjusted_laptop_cap_by_order_state(laptop_cap, state: order_state)
    @router_cap = school.adjusted_router_cap_by_order_state(router_cap, state: order_state)
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
