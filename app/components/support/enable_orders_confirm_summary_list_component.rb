class Support::EnableOrdersConfirmSummaryListComponent < SummaryListComponent
  attr_accessor :order_state, :laptop_cap, :router_cap,
                :laptop_allocation, :router_allocation,
                :change_path

  def initialize(order_state:, laptop_cap:, router_cap:, laptop_allocation:, router_allocation:, change_path:)
    @order_state = order_state
    @laptop_cap = laptop_cap
    @router_cap = router_cap
    @laptop_allocation = laptop_allocation
    @router_allocation = router_allocation
    @change_path = change_path
    super(rows:)
  end

private

  def rows
    [
      can_they_order_row,
      how_many_devices_row,
      how_many_routers_row,
    ].compact
  end

  def can_they_order_row
    {
      key: 'Can they order devices?',
      value: School.translate_enum_value(:order_state, order_state),
      change_path: change_path,
      action: 'whether they can place orders',
    }
  end

  def how_many_devices_row
    case order_state.to_sym
    when :cannot_order
      nil
    when :can_order
      {
        key: 'How many devices?',
        value: "Their full allocation of #{laptop_allocation}",
        change_path:,
        action: 'how many devices',
      }
    when :can_order_for_specific_circumstances
      {
        key: 'How many devices?',
        value: "Up to #{laptop_cap} from an allocation of #{laptop_allocation}",
        change_path:,
        action: 'how many devices',
      }
    end
  end

  def how_many_routers_row
    case order_state.to_sym
    when :cannot_order
      nil
    when :can_order
      {
        key: 'How many routers?',
        value: "Their full allocation of #{router_allocation}",
        change_path:,
        action: 'how many routers',
      }
    when :can_order_for_specific_circumstances
      {
        key: 'How many routers?',
        value: "Up to #{router_cap} from an allocation of #{router_allocation}",
        change_path:,
        action: 'how many routers',
      }
    end
  end
end
