class AllocationJob < ApplicationJob
  queue_as :default

  def perform(allocation_batch_job)
    school = allocation_batch_job.school
    order_state = allocation_batch_job.order_state
    allocation_delta = allocation_batch_job.allocation_delta.to_i
    current_allocation = SchoolDeviceAllocation.find_or_initialize_by(school: school, device_type: 'std_device')

    current_raw_allocation_value = current_allocation&.raw_allocation || 0
    new_raw_allocation_value = current_raw_allocation_value + allocation_delta

    current_raw_cap_value = current_allocation&.raw_cap || 0
    new_raw_cap_value = current_raw_cap_value + allocation_delta

    # A positive delta will always add to the raw allocation and the raw cap
    # Do not reduce the allocation or cap if the school has already over ordered
    # A negative delta where the school orders must check against raw devices ordered
    # A negative delta against a vcap pool must check devices_available_to_order for the pool
    if allocation_delta.negative?
      return unless current_allocation.devices_available_to_order.positive?

      negative_allocation_delta = [-current_allocation.devices_available_to_order, allocation_delta].max
      new_raw_allocation_value = current_raw_allocation_value + negative_allocation_delta
      new_raw_cap_value = current_raw_cap_value + negative_allocation_delta
    end

    disable_user_notifications = !allocation_batch_job.send_notification

    ActiveRecord::Base.transaction do
      current_allocation.update!(allocation: new_raw_allocation_value, cap: new_raw_cap_value)
      service = SchoolOrderStateAndCapUpdateService.new(
        school: school.reload,
        order_state: order_state,
        std_device_cap: new_raw_cap_value,
      )

      service.disable_user_notifications! if disable_user_notifications
      service.call

      if disable_user_notifications
        allocation_batch_job.update!(processed: true)
      else
        allocation_batch_job.update!(processed: true, sent_notification: true)
      end
    end
  end
end
