class Support::AllocationForm
  include ActiveModel::Model

  attr_accessor :allocation, :current_allocation, :school_allocation

  delegate :cap, :devices_ordered, to: :school_allocation

  validates :allocation, numericality: { only_integer: true, greater_than: -1 }

  def initialize(params = {})
    super(params)
    @current_allocation = @school_allocation.dup
  end

  def order_state
    school_allocation&.school&.order_state
  end
end
