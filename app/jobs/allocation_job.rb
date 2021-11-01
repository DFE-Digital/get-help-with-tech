class AllocationJob < ApplicationJob
  queue_as :default

  attr_reader :allocation_batch_job, :allocation_delta,
              :current_raw_laptop_allocation, :current_raw_laptop_cap,
              :new_raw_laptop_allocation, :new_raw_laptop_cap,
              :notify_computacenter, :notify_school, :recalculate_vcaps

  delegate :order_state, to: :allocation_batch_job
  delegate :school, to: :allocation_batch_job

  def perform(allocation_batch_job, notify_computacenter: true, recalculate_vcaps: true)
    @allocation_batch_job = allocation_batch_job
    @allocation_delta = allocation_batch_job.allocation_delta.to_i
    @notify_school = allocation_batch_job.send_notification
    @notify_computacenter = notify_computacenter
    @recalculate_vcaps = recalculate_vcaps
    recompute_laptop_allocation_numbers
    persist_changes
  end

private

  def recompute_laptop_allocation_numbers
    @current_raw_laptop_allocation = school.raw_allocation(:laptop)
    @current_raw_laptop_cap = school.raw_cap(:laptop)
    @new_raw_laptop_allocation = current_raw_laptop_allocation + allocation_delta
    @new_raw_laptop_cap = current_raw_laptop_cap + allocation_delta
    if allocation_delta.negative?
      negative_allocation_delta = [-school.devices_available_to_order(:laptop), allocation_delta].max
      @new_raw_laptop_allocation = current_raw_laptop_allocation + negative_allocation_delta
      @new_raw_laptop_cap = [current_raw_laptop_cap + negative_allocation_delta, new_raw_laptop_allocation].min
    end
  end

  def persist_changes
    ActiveRecord::Base.transaction do
      update_school_laptop_allocation
      record_batch_job_processed_and_notify
    end
  end

  def record_batch_job_processed_and_notify
    processing_params = { processed: true }
    processing_params.merge!(sent_notification: true) if notify_school
    allocation_batch_job.update!(processing_params)
  end

  def update_school_laptop_allocation
    UpdateSchoolDevicesService.new(
      school: school,
      order_state: order_state,
      laptop_allocation: new_raw_laptop_allocation,
      laptop_cap: new_raw_laptop_cap,
      notify_computacenter: notify_computacenter,
      notify_school: notify_school,
      recalculate_vcaps: recalculate_vcaps,
    ).call
  end
end
