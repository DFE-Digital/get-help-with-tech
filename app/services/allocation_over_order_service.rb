class AllocationOverOrderService
  def initialize(allocation)
    @allocation = allocation
  end

  def call
    raise(AllocationUpdater, "Can't absorb an over-order when the allocation hasn't been breached") unless @allocation.devices_over_ordered?

    # TODO: remove this when DeviceCount::devices_over_ordered is vcap aware
    raise(AllocationUpdater, "WIP: Can't handle vcap pools yet") if @allocation.school.who_will_order_devices == 'responsible_body'

    # if has_virtual_cap_feature_flags? && is_in_virtual_cap_pool?

    AllocationUpdater.new(school: @allocation.school,
                          device_type: @allocation.device_type,
                          value: @allocation.raw_devices_ordered,
                          category: :over_order).call
  end
end
