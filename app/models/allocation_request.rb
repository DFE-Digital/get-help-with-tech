class AllocationRequest < ApplicationRecord
  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :responsible_body

  validates :number_eligible, numericality: { only_integer: true, greater_than: -1, less_than: 10_000 }
  validates :number_eligible_with_hotspot_access, numericality: { only_integer: true, greater_than: -1, less_than: 10_000 }
end
