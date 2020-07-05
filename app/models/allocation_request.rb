class AllocationRequest < ApplicationRecord
  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :responsible_body

  before_validation :set_responsible_body_from_user

  validates :number_eligible, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10_000 }
  validates :number_eligible_with_hotspot_access, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10_000 }
  validates :responsible_body_id, presence: true
  validate :number_eligible_greater_than_or_equal_to_number_eligible_with_hotspot_access

private

  def set_responsible_body_from_user
    self.responsible_body_id ||= created_by_user&.responsible_body_id
  end

  def number_eligible_greater_than_or_equal_to_number_eligible_with_hotspot_access
    if number_eligible.present? && number_eligible_with_hotspot_access.present? && \
        number_eligible.to_i < number_eligible_with_hotspot_access.to_i
      errors.add(:number_eligible, :number_eligible_must_be_bigger_or_equal_to_bt_hotspot_number)
    end
  end
end
