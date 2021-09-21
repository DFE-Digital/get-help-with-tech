class UpdateSchoolDevicesService
  attr_reader :notify_school, :order_state, :school,
              :laptop_allocation, :laptop_cap, :laptop_cap_changed,
              :router_allocation, :router_cap, :router_cap_changed

  def initialize(school:, order_state:, notify_school: true, **opts)
    @laptop_allocation = laptop_allocation
    @laptop_allocation = opts[:laptop_allocation]
    @laptop_cap = opts[:laptop_cap]
    @notify_school = notify_school
    @order_state = order_state
    @router_cap = opts[:router_cap]
    @router_allocation = opts[:router_allocation]
    @school = school
  end

  def call
    update_state!
    update_allocations!
    update_caps!
    notify_other_agents unless notifications_sent_by_pool_update?

    # !!! Why in this service? and why after all the stuff above? If it succeeds agents will get notified twice (above and now)?
    add_school_to_virtual_cap_pool unless school.in_virtual_cap_pool?
    true
  end

  private

  def add_school_to_virtual_cap_pool
    unless AddSchoolToVirtualCapPoolService.new(school).call
      Rails.logger.error("Failed to add school to virtual pool (urn: #{school.urn})")
    end
  end

  def notifications_sent_by_pool_update?
    school.in_active_virtual_cap_pool?
  end

  def notify_other_agents
    allocation_ids = [school.laptop_allocation_id] if laptop_cap_changed
    allocation_ids << school.router_allocation_id if router_cap_changed
    CapUpdateNotificationsService.new(*allocation_ids, notify_school: notify_school).call if allocation_ids.any?
  end

  def update_allocations!
    school.set_laptop_allocation!(laptop_allocation) if laptop_allocation
    school.set_router_allocation!(router_allocation) if router_allocation
  end

  def update_caps!
    update_laptop_cap if laptop_cap
    update_router_cap if router_cap
  end

  def update_laptop_cap
    @laptop_cap_changed = value_changed?(school, :laptop_computacenter_cap) do
      school.set_laptop_cap!(laptop_cap)
    end
  end

  def update_router_cap
    @router_cap_changed = value_changed?(school, :router_computacenter_cap) do
      school.set_router_cap!(router_cap)
    end
  end

  def update_state!
    school.update!(order_state: order_state)
    @laptop_cap ||= school.raw_laptop_cap
    @router_cap ||= school.raw_router_cap
  end

  def value_changed?(receiver, method)
    initial = receiver.send(method)
    yield
    initial != receiver.send(method)
  end
end
