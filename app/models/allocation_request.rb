class AllocationRequest < ApplicationRecord
  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :responsible_body

  before_validation :set_responsible_body_from_user

  validates :number_eligible, numericality: { only_integer: true, greater_than: -1, less_than: 10_000 }
  validates :number_eligible_with_hotspot_access, numericality: { only_integer: true, greater_than: -1, less_than: 10_000 }

private

  def set_responsible_body_from_user
    self.responsible_body_id ||= created_by_user&.responsible_body_id
  end
end
