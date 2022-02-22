class AllocationOverOrderRevertingService
  attr_reader :cap, :device_type, :returned, :responsible_body

  def initialize(responsible_body, returned, device_type)
    @device_type = device_type
    @returned = returned
    @responsible_body = responsible_body
  end

  def call
    ResponsibleBody.transaction do
      failed_to_give_back = reclaimed_caps_in_the_vcap_pool.inject(returned) do |quantity, member|
        quantity -= give_cap_back_to_vcap_pool_member(member, quantity:)
        quantity.negative? ? quantity : break
      end
      alert_pool_cap_give_back_failed(failed_to_give_back) if failed_to_give_back
    end
  end

private

  def alert_pool_cap_give_back_failed(remaining_over_ordered_quantity)
    Sentry.with_scope do |scope|
      scope.set_context('AllocationOverOrderRevertingService#give_cap_back_across_virtual_cap_pool',
                        { responsible_body_id: responsible_body.id,
                          device_type:,
                          remaining_over_ordered_quantity: })

      Sentry.capture_message('Unable to give back enough cap in the school to revert the over-order')
    end
  end

  def reclaimed_caps_in_the_vcap_pool
    responsible_body
      .vcap_schools_with_over_order_reclaimed_cap(device_type)
      .order(Arel.sql("order_state = 'cannot_order' DESC"))
  end

  def give_cap_back_to_vcap_pool_member(member, quantity: 0)
    [member.over_order_reclaimed_devices(device_type), quantity].max.tap do |returned|
      over_order_field = member.over_order_reclaimed_devices_field(device_type)
      UpdateSchoolDevicesService.new(school: member,
                                     over_order_field => member.over_order_reclaimed_devices(device_type) - returned,
                                     notify_computacenter: false,
                                     recalculate_vcaps: false,
                                     cap_change_category: :over_order_pool_rollback).call
    end
  end
end
