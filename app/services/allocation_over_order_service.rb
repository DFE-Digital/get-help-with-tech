class AllocationOverOrderService
  attr_reader :cap, :device_type, :over_order, :responsible_body

  def initialize(responsible_body, over_order, device_type)
    @device_type = device_type
    @over_order = over_order
    @responsible_body = responsible_body
  end

  def call
    ResponsibleBody.transaction do
      failed_to_reclaim = available_caps_in_the_vcap_pool.inject(over_order) do |quantity, member|
        quantity -= reclaim_cap_from_vcap_pool_member(member, quantity:)
        quantity.positive? ? quantity : break
      end
      alert_pool_cap_reclaim_failed(failed_to_reclaim) if failed_to_reclaim
    end
  end

private

  def alert_pool_cap_reclaim_failed(remaining_over_ordered_quantity)
    Sentry.with_scope do |scope|
      scope.set_context('AllocationOverOrderService#reclaim_cap_across_virtual_cap_pool', { responsible_body_id: responsible_body.id, device_type:, remaining_over_ordered_quantity: })

      Sentry.capture_message('Unable to reclaim all of the cap in the vcap to cover the over-order')
    end
  end

  def available_caps_in_the_vcap_pool
    responsible_body.vcap_schools_that_can_lend_cap(device_type)
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
