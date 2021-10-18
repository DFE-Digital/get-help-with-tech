class AllocationJob < ApplicationJob
  queue_as :default

  def perform(allocation_batch_job)
    set_instance_variables(allocation_batch_job)
    set_default_new_raw_allocation_value
    set_default_new_raw_cap_value

    # A negative delta must check against devices_available_to_order
    set_negative_allocation_and_cap_values if @allocation_delta.negative?

    ActiveRecord::Base.transaction do
      update_school_laptop_allocation
      record_batch_job_processed_and_notify
    end
  end

private

  def set_instance_variables(allocation_batch_job)
    @allocation_batch_job = allocation_batch_job
    @school = @allocation_batch_job.school
    @order_state = @allocation_batch_job.order_state
    @allocation_delta = @allocation_batch_job.allocation_delta.to_i
    @notify_school = @allocation_batch_job.send_notification
  end

  def set_default_new_raw_allocation_value
    @current_raw_allocation_value = @school.raw_allocation(:laptop)
    @new_raw_allocation_value = @current_raw_allocation_value + @allocation_delta
  end

  def set_default_new_raw_cap_value
    @current_raw_cap_value = @school.raw_cap(:laptop)
    @new_raw_cap_value = @current_raw_cap_value + @allocation_delta
  end

  def set_negative_allocation_and_cap_values
    set_negative_allocation_delta
    set_negative_new_raw_allocation_value
    set_negative_new_raw_cap_value
  end

  def set_negative_allocation_delta
    @negative_allocation_delta = [-@school.devices_available_to_order(:laptop), @allocation_delta].max
  end

  def set_negative_new_raw_allocation_value
    @new_raw_allocation_value = @current_raw_allocation_value + @negative_allocation_delta
  end

  def set_negative_new_raw_cap_value
    @new_raw_cap_value = [@current_raw_cap_value + @negative_allocation_delta, @new_raw_allocation_value].min
  end

  def update_school_laptop_allocation
    UpdateSchoolDevicesService.new(
      school: @school.reload,
      order_state: @order_state,
      laptop_allocation: @new_raw_allocation_value,
      laptop_cap: @new_raw_cap_value,
      notify_school: @notify_school,
    ).call
  end

  def record_batch_job_processed_and_notify
    processing_params = { processed: true }
    processing_params.merge!(sent_notification: true) if @notify_school
    @allocation_batch_job.update!(processing_params)
  end
end
