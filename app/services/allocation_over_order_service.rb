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
      reclaim_allocation_across_virtual_cap_pool if school.in_active_virtual_cap_pool?
      increase_allocation_value_to_match_devices_ordered
    end
  end

private

  def alert_pool_allocation_reclaim_failed(remaining_over_ordered_quantity)
    Sentry.configure_scope do |scope|
      scope.set_context('AllocationOverOrderService#reclaim_allocation_across_virtual_cap_pool', { vcap_pool_id: @vcap_pool.id, remaining_over_ordered_quantity: remaining_over_ordered_quantity })

      Sentry.capture_message('Unable to reclaim all of the allocation in the vcap to cover the over-order')
    end
  end

  def allocation_type
    router? ? :router_allocation : :laptop_allocation
  end

  def available_allocations_in_the_vcap_pool
    vcap_pool.school_device_allocations.with_available_allocation(vcap_pool.device_type) - [allocation]
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
    to_claim = available_allocations_in_the_vcap_pool.inject(over_ordered) do |needed, member|
      needed -= reclaim_allocation_from_vcap_pool_member(member, needed: needed)
      needed.zero? ? break : needed
    end

    alert_pool_allocation_reclaim_failed(to_claim) if to_claim
  end

  def reclaim_allocation_from_vcap_pool_member(member, needed: 0)
    [member.raw_allocation - member.raw_devices_ordered, needed].min.tap do |claimed|
      unclaimed = member.raw_allocation - claimed
      UpdateSchoolDevicesService.new(school: member.school,
                                     order_state: member.school.order_state,
                                     allocation_type => unclaimed,
                                     cap_type => unclaimed,
                                     allocation_change_category: :over_order_pool_reclaim).call
    end
  end

  def router?
    device_type == 'coms_device'
  end
end
