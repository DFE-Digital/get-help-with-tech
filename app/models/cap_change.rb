class CapChange < ApplicationRecord
  belongs_to :school

  enum category: {
    allocation_change: 'allocation_change',
    allocation_job: 'allocation_job',
    cap_usage: 'cap_usage',
    enable_orders: 'enable_orders',
    get_allocations_from_predecessor: 'get_allocations_from_predecessor',
    give_allocations_to_successor: 'give_allocations_to_successor',
    import_device_allocations: 'import_device_allocations',
    over_order_pool_rollback: 'over_order_pool_rollback',
    over_order_pool_reclaim: 'over_order_pool_reclaim',
    service_closure: 'service_closure',
  }
end
