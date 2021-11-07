class Support::ServicePerformance::DeviceCounts
  def self.sum_allocation(school_scope:, who_will_order_devices:, sum_expression:, scope_query: nil)
    School
      .where(scope_query)
      .merge(school_scope)
      .where(who_will_order_devices: who_will_order_devices)
      .sum(sum_expression)
  end

  attr_reader :device_type, :key, :school_scope, :who_will_order_devices

  def initialize(key:, school_scope:, device_type:, who_will_order_devices:)
    @key = key
    @school_scope = school_scope
    @device_type = device_type
    @who_will_order_devices = who_will_order_devices
  end

  def available
    sum_allocation(sum_expression: raw_cap)
  end

  def ordered
    sum_allocation(sum_expression: devices_ordered)
  end

  def remaining_excl_over_ordered
    sum_allocation(
      scope_query: not_over_ordered_allocation_query,
      sum_expression: not_over_ordered_quantity,
    )
  end

  def over_ordered
    sum_allocation(
      scope_query: over_ordered_allocation_query,
      sum_expression: over_ordered_quantity,
    )
  end

private

  def raw_cap
    "(raw_#{device_type}_allocation + over_order_reclaimed_#{device_type}s + circumstances_#{device_type}s)"
  end

  def devices_ordered
    "raw_#{device_type}s_ordered"
  end

  def not_over_ordered_allocation_query
    "#{raw_cap} >= raw_#{device_type}s_ordered"
  end

  def not_over_ordered_quantity
    "#{raw_cap} - raw_#{device_type}s_ordered"
  end

  def over_ordered_quantity
    "raw_#{device_type}s_ordered - #{raw_cap}"
  end

  def over_ordered_allocation_query
    "raw_#{device_type}s_ordered > 0 AND #{raw_cap} < raw_#{device_type}s_ordered"
  end

  def sum_allocation(sum_expression:, scope_query: nil)
    self.class.sum_allocation(
      school_scope: school_scope,
      who_will_order_devices: who_will_order_devices,
      sum_expression: sum_expression,
      scope_query: scope_query,
    )
  end
end
