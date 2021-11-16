class AllocationOverOrderRevertingService
  attr_reader :cap, :device_type, :devices, :school

  def initialize(school, devices, device_type)
    @device_type = device_type
    @devices = devices
    @school = school
  end

  def call
    give_cap_back_across_virtual_cap_pool if school.vcap?
  end

private

  def alert_pool_cap_give_back_failed(remaining_over_ordered_quantity)
    Sentry.with_scope do |scope|
      scope.set_context('AllocationOverOrderRevertingService#give_cap_back_across_virtual_cap_pool',
                        { school_id: school.id,
                          device_type: device_type,
                          remaining_over_ordered_quantity: remaining_over_ordered_quantity })

      Sentry.capture_message('Unable to give back enough cap in the school to revert the over-order')
    end
  end

  def stolen_caps_in_the_vcap_pool
    school.responsible_body.vcap_schools.with_over_order_stolen_cap(device_type)
  end

  def give_cap_back_across_virtual_cap_pool
    School.transaction do
      failed_to_give_back = stolen_caps_in_the_vcap_pool.inject(devices) do |quantity, member|
        quantity -= give_cap_back_to_vcap_pool_member(member, quantity: quantity)
        quantity.negative? ? quantity : break
      end
      alert_pool_cap_give_back_failed(failed_to_give_back) if failed_to_give_back
    end
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
