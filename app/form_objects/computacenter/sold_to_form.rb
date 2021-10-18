class Computacenter::SoldToForm
  include ActiveModel::Model

  attr_accessor :change_sold_to, :sold_to, :responsible_body

  validates :sold_to, numericality: { only_integer: true, message: 'Sold To must be a number' }
  validates :change_sold_to, inclusion: { in: %w[yes no], message: 'Tell us whether the Sold To number needs to change' }

  def save
    valid? && update_responsible_body && update_computacenter
  end

private

  def update_computacenter
    updates = responsible_body.schools.map(&:cap_updates)
    CapUpdateNotificationsService.new(*updates.flatten, notify_computacenter: false, notify_school: false).call
  end

  def update_responsible_body
    responsible_body.update(computacenter_reference: sold_to, computacenter_change: 'none')
  end
end
