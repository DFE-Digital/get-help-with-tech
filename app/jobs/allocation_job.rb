class AllocationJob < ApplicationJob
  queue_as :default

  attr_reader :allocation_batch_job, :allocation_delta,
              :applied_allocation_delta, :new_raw_laptop_allocation,
              :notify_computacenter, :notify_school, :recalculate_vcaps

  delegate :order_state, to: :allocation_batch_job
  delegate :school, to: :allocation_batch_job
  delegate :raw_allocation, :over_order_reclaimed_devices, :circumstances_devices, :raw_devices_ordered,
           to: :school

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
    raw_cap = raw_allocation(:laptop) + over_order_reclaimed_devices(:laptop) + circumstances_devices(:laptop)
    @applied_allocation_delta = [-[0, raw_cap - raw_devices_ordered(:laptop)].max, allocation_delta].max
    @new_raw_laptop_allocation = raw_allocation(:laptop) + applied_allocation_delta
  end

  def persist_changes
    ActiveRecord::Base.transaction do
      update_school_laptop_allocation
      record_batch_job_processed_and_notify
    end
  end

  def record_batch_job_processed_and_notify
    processing_params = { processed: true, applied_allocation_delta: applied_allocation_delta }
    processing_params.merge!(sent_notification: true) if notify_school
    allocation_batch_job.update!(processing_params)
  end

  def update_school_laptop_allocation
    UpdateSchoolDevicesService.new(
      school: school,
      order_state: order_state,
      laptop_allocation: new_raw_laptop_allocation,
      notify_computacenter: notify_computacenter,
      notify_school: notify_school,
      recalculate_vcaps: recalculate_vcaps,
      cap_change_category: :allocation_job,
    ).call
  end
end
