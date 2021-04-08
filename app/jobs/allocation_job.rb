class AllocationJob < ApplicationJob
  queue_as :default

  def perform(allocation_batch_job)
    school = allocation_batch_job.school
    order_state = allocation_batch_job.order_state
    current_allocation = school.std_device_allocation

    current_allocation_value = current_allocation&.allocation || 0
    new_allocation_value = current_allocation_value + allocation_batch_job.allocation_delta

    current_cap_value = current_allocation&.cap || 0
    new_cap_value = current_cap_value + allocation_batch_job.allocation_delta

    disable_user_notifications = !allocation_batch_job.send_notification

    allocation = SchoolDeviceAllocation.find_or_initialize_by(school: school, device_type: 'std_device')

    ActiveRecord::Base.transaction do
      allocation.update!(allocation: new_allocation_value)

      service = SchoolOrderStateAndCapUpdateService.new(
        school: school,
        order_state: order_state,
        std_device_cap: new_cap_value,
      )

      service.disable_user_notifications! if disable_user_notifications
      service.call

      allocation_batch_job.update!(processed: true)
    end
  end
end
