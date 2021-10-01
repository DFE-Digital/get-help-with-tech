class UpdateSchoolDevicesService
  attr_reader :allocation_change_category, :allocation_change_description,
              :laptop_allocation, :laptop_cap, :laptop_cap_changed,
              :notify_school, :order_state, :school,
              :router_allocation, :router_cap, :router_cap_changed

  def initialize(school:, order_state:, notify_school: true, **opts)
    @allocation_change_category = opts[:allocation_change_category]
    @allocation_change_description = opts[:allocation_change_description]
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
    update_devices_ordering!
    notify_other_agents unless notifications_sent_by_pool_update?
    true
  end

  private

  def notifications_sent_by_pool_update?
    school.in_active_virtual_cap_pool?
  end

  def notify_other_agents
    allocation_ids = laptop_cap_changed ? [school.laptop_allocation_id] : []
    allocation_ids << school.router_allocation_id if router_cap_changed
    CapUpdateNotificationsService.new(*allocation_ids, notify_school: notify_school).call if allocation_ids.any?
  end

  def record_allocation_change_meta_data(allocation_id:, prev_allocation:, new_allocation:)
    if allocation_change_category || allocation_change_description
      AllocationChange.create!(school_device_allocation_id: allocation_id,
                               category: allocation_change_category,
                               delta: laptop_allocation - school.raw_laptop_allocation,
                               prev_allocation: prev_allocation,
                               new_allocation: new_allocation,
                               description: allocation_change_description)
    end
  end

  def update_devices_ordering!
    update_laptop_ordering! if laptop_allocation || laptop_cap
    update_router_ordering! if router_allocation || router_cap
  end

  def update_laptop_ordering!
    @laptop_cap_changed = value_changed?(school, :laptop_computacenter_cap) do
      School.transaction do
        record_allocation_change_meta_data(allocation_id: school.laptop_allocation_id,
                                           prev_allocation: school.raw_laptop_allocation,
                                           new_allocation: laptop_allocation)
        school.set_laptop_ordering!(cap: laptop_cap, allocation: laptop_allocation)
      end
    end
  end

  def update_router_ordering!
    @router_cap_changed = value_changed?(school, :router_computacenter_cap) do
      School.transaction do
        record_allocation_change_meta_data(allocation_id: school.router_allocation_id,
                                           prev_allocation: school.raw_router_allocation,
                                           new_allocation: router_allocation)
        school.set_router_ordering!(cap: router_cap, allocation: router_allocation)
      end
    end
  end

  def update_state!
    school.update!(order_state: order_state)
  end

  def value_changed?(receiver, method)
    initial = receiver.send(method)
    yield
    initial != receiver.send(method)
  end
end
