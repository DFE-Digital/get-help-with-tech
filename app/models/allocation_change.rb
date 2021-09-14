class AllocationChange < ApplicationRecord
  belongs_to :school_device_allocation

  enum category: {
    allocation_error_reversal: 'allocation_error_reversal',
    over_order: 'over_order',
    service_closure: 'service_closure',
    unused_allocation_reclaim: 'unused_allocation_reclaim',
    uplift: 'uplift',
  }
end
