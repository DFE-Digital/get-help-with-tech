class RemoveSchoolFromVirtualCapPoolService
  attr_reader :school, :rb

  delegate :laptop_allocation_id, :router_allocation_id, to: :school

  def initialize(school, responsible_body)
    @school = school
    @rb = responsible_body
  end

  def call
    remove_school! if school.in_virtual_cap_pool?
  rescue StandardError => e
    failed(e)
  end

  private

  def remove_school!
    school.transaction do
      remove_devices_from_pools!
      rb.calculate_virtual_caps!
      school.reload.refresh_device_ordering_status!
      true
    end
  end

  def remove_devices_from_pools!
    remove_laptop_from_pool! if laptop_allocation_id
    remove_router_from_pool! if router_allocation_id
  end

  def remove_laptop_from_pool!
    remove_device_allocation_from_pool!(laptop_allocation_id)
  end

  def remove_router_from_pool!
    remove_device_allocation_from_pool!(router_allocation_id)
  end

  def remove_device_allocation_from_pool!(allocation_id)
    SchoolVirtualCap.find_by(school_device_allocation_id: allocation_id)
      &.destroy!
      # &.recalculate_caps!
  end

  def failed(e)
    log_error(e)
    false
  end

  def log_error(e)
    school.errors.add(:base, e.message)
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end
end
