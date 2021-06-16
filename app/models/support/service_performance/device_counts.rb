class Support::ServicePerformance::DeviceCounts
  OVER_ORDERED_ALLOCATION_QUERY = 'devices_ordered > 0 AND cap < devices_ordered'.freeze
  NOT_OVER_ORDERED_ALLOCATION_QUERY = 'cap >= devices_ordered'.freeze

  def self.sum_allocation(
    school_scope:,
    device_type:,
    who_will_order_devices:,
    sum_expression:,
    scope_query: nil
  )
    SchoolDeviceAllocation
      .where(device_type: device_type)
      .where(scope_query)
      .joins(school: :preorder_information)
      .merge(school_scope)
      .where(preorder_information: {
        who_will_order_devices: who_will_order_devices,
      })
      .sum(sum_expression)
  end

  attr_reader :key

  def initialize(
    key:,
    school_scope:,
    device_type:,
    who_will_order_devices:
  )
    @key = key
    @school_scope = school_scope
    @device_type = device_type
    @who_will_order_devices = who_will_order_devices
  end

  def available
    sum_allocation(sum_expression: 'cap')
  end

  def ordered
    sum_allocation(sum_expression: 'devices_ordered')
  end

  def remaining_excl_over_ordered
    sum_allocation(
      scope_query: NOT_OVER_ORDERED_ALLOCATION_QUERY,
      sum_expression: 'cap - devices_ordered',
    )
  end

  def over_ordered
    sum_allocation(
      scope_query: OVER_ORDERED_ALLOCATION_QUERY,
      sum_expression: 'devices_ordered - cap',
    )
  end

private

  def sum_allocation(sum_expression:, scope_query: nil)
    self.class.sum_allocation(
      school_scope: @school_scope,
      device_type: @device_type,
      who_will_order_devices: @who_will_order_devices,
      sum_expression: sum_expression,
      scope_query: scope_query,
    )
  end
end
