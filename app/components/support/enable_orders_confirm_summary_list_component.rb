class Support::EnableOrdersConfirmSummaryListComponent < SummaryListComponent
  attr_accessor :order_state, :cap, :allocation, :change_path

  def initialize(order_state:, cap:, allocation:, change_path:)
    @order_state = order_state
    @cap = cap
    @allocation = allocation
    @change_path = change_path
    super(rows: rows)
  end

private

  def rows
    [
      can_they_order_row,
      how_many_devices_row,
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
        value: "Their full allocation of #{allocation}",
        change_path: change_path,
        action: 'how many devices',
      }
    when :can_order_for_specific_circumstances
      {
        key: 'How many devices?',
        value: "Up to #{cap} from an allocation of #{allocation}",
        change_path: change_path,
        action: 'how many devices',
      }
    end
  end
end
