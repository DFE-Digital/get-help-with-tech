class AllocationOverOrderService
  attr_reader :allocation, :device_type, :over_order, :school

  def initialize(school, over_order, device_type)
    @device_type = device_type
    @over_order = over_order
    @school = school
  end

  def call
    reclaim_allocation_across_virtual_cap_pool if school.in_virtual_cap_pool?
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

  def reclaim_allocation_across_virtual_cap_pool
    School.transaction do
      to_reclaim = available_allocations_in_the_vcap_pool.inject(over_order) do |quantity, member|
        quantity -= reclaim_allocation_from_vcap_pool_member(member, quantity: quantity)
        quantity.zero? ? break : quantity
      end
      alert_pool_allocation_reclaim_failed(to_reclaim) if to_reclaim
    end
  end

  def reclaim_allocation_from_vcap_pool_member(member, quantity: 0)
    allocation = member.raw_allocation(device_type)
    devices_ordered = member.raw_devices_ordered(device_type)
    [allocation - devices_ordered, quantity].min.tap do |claimed|
      unclaimed = allocation - claimed
      UpdateSchoolDevicesService.new(school: member,
                                     allocation_type => unclaimed,
                                     cap_type => unclaimed,
                                     allocation_change_category: :over_order_pool_reclaim).call
    end
  end

  def router?
    device_type == :router
  end
end
