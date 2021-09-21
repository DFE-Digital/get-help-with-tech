class Computacenter::ShipToForm
  include ActiveModel::Model

  attr_accessor :change_ship_to, :ship_to, :school

  validates :ship_to, numericality: { only_integer: true, message: 'Ship To must be a number' }
  validates :change_ship_to, inclusion: { in: %w[yes no], message: 'Tell us whether the Ship To number needs to change' }

  def initialize(params = {})
    super(params)
  end

  def save
    valid? && update_school && update_computacenter
  end

  private

  def update_computacenter
    CapUpdateNotificationsService.new(*school.allocation_ids, notify_computacenter: false, notify_school: false).call
  end

  def update_school
    school.update(computacenter_reference: ship_to, computacenter_change: 'none').errors.none?
  end
end
