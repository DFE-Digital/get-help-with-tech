class Support::EnableOrdersForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  DEVICE_TYPES = %i[laptop router].freeze

  attr_accessor :order_state,
                :school
  attr_reader   :laptop_cap,
                :router_cap

  validates :order_state, inclusion: { in: School.order_states.keys }
  validates :laptop_cap, presence: true, if: :cap_required?
  validates :laptop_cap, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }, if: :cap_required?
  validates :router_cap, presence: true, if: :cap_required?
  validates :router_cap, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }, if: :cap_required?

  validate :validate_caps, if: :cap_required?
  validate :validate_circumstances_devices, if: :cap_required?

  delegate :over_order_reclaimed_devices,
           :raw_allocation,
           :raw_devices_ordered,
           to: :school

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
    order_state.to_sym.in?(%i[can_order_for_specific_circumstances can_order])
  end

private

  def cap_assigned(device_type)
    laptop?(device_type) ? laptop_cap : router_cap
  end

  def cap_assigned_field(device_type)
    laptop?(device_type) ? :laptop_cap : :router_cap
  end

  def cap_required?
    order_state.to_sym == :can_order_for_specific_circumstances
  end

  def circumstances_props
    {
      circumstances_laptops: circumstances_devices(:laptop),
      circumstances_routers: circumstances_devices(:router),
    }
  end

  def circumstances_devices(device_type)
    cap_assigned(device_type) - (raw_allocation(device_type) + over_order_reclaimed_devices(device_type))
  end

  def laptop?(device_type)
    device_type.to_sym == :laptop
  end

  def orders_enabled?
    opts = cap_required? ? circumstances_props : {}
    UpdateSchoolDevicesService.new(school: school, order_state: order_state, **opts).call
  end

  def validate_circumstances_devices
    DEVICE_TYPES.each do |device_type|
      if cap_required? && circumstances_devices(device_type).positive?
        errors.add(cap_assigned_field(device_type), :lte_allocation, allocation: raw_allocation(device_type))
      end
    end
  end

  def validate_caps
    DEVICE_TYPES.each do |device_type|
      devices_ordered = raw_devices_ordered(device_type)
      next if cap_assigned(device_type) >= devices_ordered

      errors.add(cap_assigned_field(device_type), :gte_devices_ordered, devices_ordered: devices_ordered)
    end
  end
end
