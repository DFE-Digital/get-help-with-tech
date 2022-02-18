class Support::ServicePerformance::DeviceCounts
  attr_reader :key, :school_scope, :who_will_order_devices

  def initialize(key:, who_will_order_devices:, school_scope: School)
    @key = key
    @school_scope = school_scope
    @who_will_order_devices = who_will_order_devices
  end

  def allocation_liability
    @allocation_liability ||= cap - ordered
  end

  def allocated
    @allocated ||= cap - over_ordered
  end

  def cap
    @cap ||= sum_allocation(
      Arel.sql("CASE order_state WHEN 'cannot_order'
                           THEN raw_laptops_ordered
                           ELSE raw_laptop_allocation + over_order_reclaimed_laptops + circumstances_laptops
                       END"),
    )
  end

  def over_ordered
    @over_ordered ||= sum_allocation(Arel.sql('over_order_reclaimed_laptops'))
  end

  def ordered
    @ordered ||= sum_allocation('raw_laptops_ordered')
  end

private

  def sum_allocation(sum_expression)
    school_scope.where(who_will_order_devices: who_will_order_devices).sum(sum_expression)
  end
end
