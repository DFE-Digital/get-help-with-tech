class AllocationChange < ApplicationRecord

  #### PENDING MIGRATIONS
  ####   Add :device_type
  ####   Add :school_id
  ####   Remove :school_device_allocation_id

  belongs_to :school

  enum category: {
    allocation_error_reversal: 'allocation_error_reversal',
    increase: 'increase',
    over_order: 'over_order',
    over_order_pool_reclaim: 'over_order_pool_reclaim',
    service_closure: 'service_closure',
    unused_allocation_reclaim: 'unused_allocation_reclaim',
  }
end
