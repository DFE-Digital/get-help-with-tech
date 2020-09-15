class Support::EnableOrdersForm
  include ActiveModel::Model

  attr_accessor :order_state, :cap

  validates :order_state, inclusion: { in: School.order_states }
  validates :cap, numericality: { only_integer: true, greater_than: 0 }, if: :cap_required?

  def cap_required?
    order_state.to_s == 'can_order_for_specific_circumstances'
  end
end
