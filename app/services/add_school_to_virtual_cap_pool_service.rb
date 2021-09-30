class AddSchoolToVirtualCapPoolService
  attr_reader :school, :rb

  delegate :addable_to_virtual_cap_pool?,
           :laptop_allocation_id, :router_allocation_id,
           :raw_laptop_cap, :raw_router_cap,
           :raw_laptops_ordered, :raw_routers_ordered,
           :in_virtual_cap_pool?, :responsible_body, to: :school

  def initialize(school)
    @school = school
    @rb = responsible_body
  end

  def call
    return true if in_virtual_cap_pool?(responsible_body_id: rb.id)

    add_school! if addable?
  rescue StandardError => e
    failed(e)
  end

private

  def addable?
    rb.has_virtual_cap_feature_flags? && addable_to_virtual_cap_pool?
  end

  def add_school!
    add_devices_to_pools!
    school.reload.refresh_device_ordering_status!
    true
  end

  def add_devices_to_pools!
    add_laptop_to_pool!(raw_laptop_cap == raw_laptops_ordered) if laptop_allocation_id
    add_router_to_pool!(raw_router_cap == raw_routers_ordered) if router_allocation_id
  end

  def add_laptop_to_pool!(notify)
    add_device_allocation_to_pool!(laptop_allocation_id, laptop_pool, notify: notify)
  end

  def add_router_to_pool!(notify)
    add_device_allocation_to_pool!(router_allocation_id, router_pool, notify: notify)
  end

  def add_device_allocation_to_pool!(allocation_id, pool, notify: true)
    SchoolVirtualCap.find_or_initialize_by(school_device_allocation_id: allocation_id)
                    .update!(virtual_cap_pool_id: pool.id)
    if notify # pool has not sent notifications because pool aggregated numbers haven't changed
      CapUpdateNotificationsService.new(allocation_id, notify_computacenter: false, notify_school: false).call
    end
  end

  def failed(e)
    log_error(e)
    false
  end

  def laptop_pool
    @laptop_virtual_cap_pool = rb.std_device_pool || rb.create_std_device_pool!
  end

  def log_error(e)
    school.errors.add(:base, e.message)
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end

  def router_pool
    @router_virtual_cap_pool = rb.coms_device_pool || rb.create_coms_device_pool!
  end
end
