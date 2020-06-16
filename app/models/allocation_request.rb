class AllocationRequest < ApplicationRecord
  # NOTE the `optional: true` is so that the form object can save the user
  # before allocation_request.
  belongs_to :created_by_user, class_name: 'User', optional: true
  validates :number_eligible, numericality: { only_integer: true, greater_than: -1, less_than: 10_000 }
  validates :number_eligible_with_hotspot_access, numericality: { only_integer: true, greater_than: -1, less_than: 10_000 }
end
