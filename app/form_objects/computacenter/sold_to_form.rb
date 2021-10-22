class Computacenter::SoldToForm
  include ActiveModel::Model

  DEVICE_TYPES = %i[laptop router].freeze

  attr_accessor :change_sold_to, :sold_to, :responsible_body

  validates :sold_to, numericality: { only_integer: true, message: 'Sold To must be a number' }
  validates :change_sold_to, inclusion: { in: %w[yes no], message: 'Tell us whether the Sold To number needs to change' }

  def save
    valid? && update_responsible_body && update_computacenter
  end

private

  def update_computacenter
    CapUpdateNotificationsService.new(*responsible_body.schools,
                                      device_types: DEVICE_TYPES,
                                      notify_computacenter: false,
                                      notify_school: false).call
  end

  def update_responsible_body
    responsible_body.update(computacenter_reference: sold_to, computacenter_change: 'none')
  end
end
