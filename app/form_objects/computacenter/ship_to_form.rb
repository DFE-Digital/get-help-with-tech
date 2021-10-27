class Computacenter::ShipToForm
  include ActiveModel::Model

  DEVICE_TYPES = %i[laptop router].freeze

  attr_accessor :change_ship_to, :ship_to, :school

  validates :ship_to, numericality: { only_integer: true, message: 'Ship To must be a number' }
  validates :change_ship_to, inclusion: { in: %w[yes no], message: 'Tell us whether the Ship To number needs to change' }

  def save
    valid? && update_school && update_computacenter
  end

private

  def update_computacenter
    CapUpdateNotificationsService.new(school,
                                      device_types: DEVICE_TYPES,
                                      notify_computacenter: false,
                                      notify_school: false).call
  end

  def update_school
    school.update(computacenter_reference: ship_to, computacenter_change: 'none')
  end
end
