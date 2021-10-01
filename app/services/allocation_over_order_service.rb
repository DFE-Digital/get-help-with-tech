class AllocationOverOrderService
  attr_reader :allocation, :device_type, :raw_allocation, :raw_devices_ordered,
              :school, :vcap_pool

  def initialize(allocation)
    @allocation = allocation
    @device_type = allocation.device_type
    @school = allocation.school
    @raw_allocation = allocation.raw_allocation
    @raw_devices_ordered = allocation.raw_devices_ordered
    @vcap_pool = allocation.virtual_cap_pool
  end

  def call
    SchoolDeviceAllocation.transaction do
      if allocation_is_in_virtual_cap_pool?
        reclaim_allocation_across_virtual_cap_pool
      end

      increase_allocation_value_to_match_devices_ordered
    end
  end

  private

  def reclaim_allocation_across_virtual_cap_pool
    remaining_over_ordered_quantity = over_ordered_quantity
    available_allocations_in_the_vcap_pool.each do |allocation|
      available_allocation_quantity = [raw_allocation - raw_devices_ordered, remaining_over_ordered_quantity].min
      new_raw_allocation_value = raw_allocation - available_allocation_quantity

      reclaim_allocation_from_vcap_pool_member(allocation, new_raw_allocation_value)

      remaining_over_ordered_quantity -= available_allocation_quantity
      break if remaining_over_ordered_quantity.zero?
    end

    alert_pool_allocation_reclaim_failed(remaining_over_ordered_quantity) if remaining_over_ordered_quantity.positive?
  end

  def alert_pool_allocation_reclaim_failed(remaining_over_ordered_quantity)
    Sentry.configure_scope do |scope|
      scope.set_context('AllocationOverOrderService#reclaim_allocation_across_virtual_cap_pool', { vcap_pool_id: @vcap_pool.id, remaining_over_ordered_quantity: remaining_over_ordered_quantity })

      Sentry.capture_message('Unable to reclaim all of the allocation in the vcap to cover the over-order')
    end
  end

  def allocation_is_in_virtual_cap_pool?
    school&.responsible_body&.has_virtual_cap_feature_flags? && allocation.is_in_virtual_cap_pool?
  end

  def over_ordered_quantity
    raw_devices_ordered - raw_allocation
  end

  def available_allocations_in_the_vcap_pool
    vcap_pool.school_device_allocations.with_available_allocation(vcap_pool.device_type)
  end

  def reclaim_allocation_from_vcap_pool_member(allocation, new_allocation_value)
    AllocationForm.new(school: allocation.school,
                       device_type: allocation.device_type,
                       allocation: new_allocation_value,
                       category: :over_order_pool_reclaim).save
  end

  def increase_allocation_value_to_match_devices_ordered
    AllocationForm.new(school: school,
                       device_type: device_type,
                       allocation: raw_devices_ordered,
                       category: :over_order,
                       description: 'Over Order').save
  end
end
