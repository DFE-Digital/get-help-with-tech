class AllocationJob < ApplicationJob
  queue_as :default

  def perform(allocation_batch_job)
    set_instance_variables(allocation_batch_job)
    set_default_new_raw_allocation_value
    set_default_new_raw_cap_value

    # A negative delta must check against devices_available_to_order
    set_negative_allocation_and_cap_values if @allocation_delta.negative?

    ActiveRecord::Base.transaction do
      update_current_allocation!
      call_school_order_state_and_cap_update_service
      record_batch_job_processed_and_notify
    end
  end

private

  def set_instance_variables(allocation_batch_job)
    @allocation_batch_job = allocation_batch_job
    @school = @allocation_batch_job.school
    @order_state = @allocation_batch_job.order_state
    @allocation_delta = @allocation_batch_job.allocation_delta.to_i
    @disable_user_notifications = !@allocation_batch_job.send_notification
    @current_allocation = SchoolDeviceAllocation.find_or_initialize_by(school: @school, device_type: 'std_device')
  end

  def set_default_new_raw_allocation_value
    @current_raw_allocation_value = @current_allocation&.raw_allocation || 0
    @new_raw_allocation_value = @current_raw_allocation_value + @allocation_delta
  end

  def set_default_new_raw_cap_value
    @current_raw_cap_value = @current_allocation&.raw_cap || 0
    @new_raw_cap_value = @current_raw_cap_value + @allocation_delta
  end

  def set_negative_allocation_and_cap_values
    set_negative_allocation_delta
    set_negative_new_raw_allocation_value
    set_negative_new_raw_cap_value
  end

  def set_negative_allocation_delta
    @negative_allocation_delta = [-@current_allocation.devices_available_to_order, @allocation_delta].max
  end

  def set_negative_new_raw_allocation_value
    @new_raw_allocation_value = @current_raw_allocation_value + @negative_allocation_delta
  end

  def set_negative_new_raw_cap_value
    @new_raw_cap_value = [@current_raw_cap_value + @negative_allocation_delta, @new_raw_allocation_value].min
  end

  def update_current_allocation!
    if @allocation_delta.negative? && @new_raw_allocation_value < @current_allocation.raw_cap
      @current_allocation.update!(allocation: @new_raw_allocation_value, cap: @new_raw_cap_value)
    else
      @current_allocation.update!(allocation: @new_raw_allocation_value)
    end
  end

  def call_school_order_state_and_cap_update_service
    service = SchoolOrderStateAndCapUpdateService.new(
      school: @school.reload,
      order_state: @order_state,
      std_device_cap: @new_raw_cap_value,
    )

    service.disable_user_notifications! if @disable_user_notifications
    service.call
  end

  def record_batch_job_processed_and_notify
    if @disable_user_notifications
      return @allocation_batch_job.update!(processed: true)
    end

    @allocation_batch_job.update!(processed: true, sent_notification: true)
  end
end
