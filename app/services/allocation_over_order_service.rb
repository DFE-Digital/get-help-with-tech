class AllocationOverOrderService
  attr_reader :allocation, :device_type, :raw_allocation, :raw_devices_ordered, :school

  def initialize(school, device_type)
    @device_type = device_type
    @school = school
    @raw_allocation = school.raw_allocation(device_type)
    @raw_devices_ordered = school.raw_devices_ordered(device_type)
  end

  def call
    School.transaction do
      reclaim_allocation_across_virtual_cap_pool if school.in_virtual_cap_pool?
      increase_allocation_value_to_match_devices_ordered
    end
  end

private

  def alert_pool_allocation_reclaim_failed(remaining_over_ordered_quantity)
    Sentry.with_scope do |scope|
      scope.set_context('AllocationOverOrderService#reclaim_allocation_across_virtual_cap_pool', { school_id: school.id, device_type: device_type, remaining_over_ordered_quantity: remaining_over_ordered_quantity })

      Sentry.capture_message('Unable to reclaim all of the allocation in the vcap to cover the over-order')
    end
  end

  def allocation_type
    router? ? :router_allocation : :laptop_allocation
  end

  def available_allocations_in_the_vcap_pool
    school.responsible_body.vcap_schools.with_available_allocation(device_type).to_a - [school]
  end

  def cap_type
    router? ? :router_cap : :laptop_cap
  end

  def increase_allocation_value_to_match_devices_ordered
    UpdateSchoolDevicesService.new(school: school,
                                   order_state: school.order_state,
                                   allocation_type => raw_devices_ordered,
                                   cap_type => raw_devices_ordered,
                                   allocation_change_category: :over_order,
                                   allocation_change_description: 'Over Order').call
  end

  def over_ordered
    raw_devices_ordered - raw_allocation
  end

  def reclaim_allocation_across_virtual_cap_pool
    to_reclaim = available_allocations_in_the_vcap_pool.inject(over_ordered) do |quantity, member|
      quantity -= reclaim_allocation_from_vcap_pool_member(member, quantity: quantity)
      quantity.zero? ? break : quantity
    end

    alert_pool_allocation_reclaim_failed(to_reclaim) if to_reclaim
  end

  def reclaim_allocation_from_vcap_pool_member(member, quantity: 0)
    allocation = member.raw_allocation(device_type)
    devices_ordered = member.raw_devices_ordered(device_type)
    [allocation - devices_ordered, quantity].min.tap do |claimed|
      unclaimed = allocation - claimed
      UpdateSchoolDevicesService.new(school: member,
                                     order_state: member.order_state,
                                     allocation_type => unclaimed,
                                     cap_type => unclaimed,
                                     allocation_change_category: :over_order_pool_reclaim).call
    end
  end

  def router?
    device_type == :router
  end
end
