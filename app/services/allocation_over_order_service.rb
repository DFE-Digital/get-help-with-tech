class AllocationOverOrderService
  attr_reader :cap, :device_type, :over_order, :school

  def initialize(school, over_order, device_type)
    @device_type = device_type
    @over_order = over_order
    @school = school
  end

  def call
    reclaim_cap_across_virtual_cap_pool if school.vcap?
  end

private

  def alert_pool_cap_reclaim_failed(remaining_over_ordered_quantity)
    Sentry.with_scope do |scope|
      scope.set_context('AllocationOverOrderService#reclaim_cap_across_virtual_cap_pool', { school_id: school.id, device_type: device_type, remaining_over_ordered_quantity: remaining_over_ordered_quantity })

      Sentry.capture_message('Unable to reclaim all of the cap in the vcap to cover the over-order')
    end
  end

  def available_caps_in_the_vcap_pool
    school.responsible_body.vcap_schools.with_available_cap(device_type).to_a - [school]
  end

  def reclaim_cap_across_virtual_cap_pool
    School.transaction do
      failed_to_reclaim = available_caps_in_the_vcap_pool.inject(over_order) do |quantity, member|
        quantity -= reclaim_cap_from_vcap_pool_member(member, quantity: quantity)
        quantity.positive? ? quantity : break
      end
      alert_pool_cap_reclaim_failed(failed_to_reclaim) if failed_to_reclaim
    end
  end

  def reclaim_cap_from_vcap_pool_member(member, quantity: 0)
    [member.raw_devices_available_to_order(device_type), quantity].min.tap do |claimed|
      over_order_field = member.over_order_reclaimed_devices_field(device_type)
      UpdateSchoolDevicesService.new(school: member,
                                     over_order_field => member.over_order_reclaimed_devices(device_type) - claimed,
                                     notify_computacenter: false,
                                     recalculate_vcaps: false,
                                     cap_change_category: :over_order_pool_reclaim).call
    end
  end
end
