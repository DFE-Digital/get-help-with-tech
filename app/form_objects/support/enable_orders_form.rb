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
    @laptop_cap = UpdateSchoolDevicesService.new(school: school, order_state: order_state)
                                            .adjusted_cap_by_order_state(laptop_cap, device_type: :laptop)
    @router_cap = UpdateSchoolDevicesService.new(school: school, order_state: order_state)
                                            .adjusted_cap_by_order_state(router_cap, device_type: :router)
  end

  def validate_caps_lte_allocation
    if laptop_cap.to_i > school.allocation(:laptop)
      errors.add(:laptop_cap, :lte_allocation, allocation: school.allocation(:laptop))
    end

    if router_cap.to_i > school.allocation(:router)
      errors.add(:router_cap, :lte_allocation, allocation: school.allocation(:router))
    end
  end
end
