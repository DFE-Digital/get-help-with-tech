class UpdateSchoolDevicesService
  attr_reader :allocation_change_category, :allocation_change_description,
              :laptop_allocation, :laptop_cap, :laptop_cap_changed,
              :notify_computacenter, :notify_school, :order_state, :school,
              :router_allocation, :router_cap, :router_cap_changed

  def initialize(school:, order_state:, notify_school: true, notify_computacenter: true, **opts)
    @allocation_change_category = opts[:allocation_change_category]
    @allocation_change_description = opts[:allocation_change_description]
    @laptop_allocation = opts[:laptop_allocation]
    @laptop_cap = opts[:laptop_cap]
    @notify_computacenter = notify_computacenter
    @notify_school = notify_school
    @order_state = order_state
    @router_cap = opts[:router_cap]
    @router_allocation = opts[:router_allocation]
    @school = school
  end

  def adjusted_cap_by_order_state(cap, device_type:)
    return school.raw_devices_ordered(device_type) if order_state == 'cannot_order'
    return school.raw_allocation(device_type) if order_state == 'can_order'

    cap || school.raw_cap(device_type)
  end

  def call
    School.transaction do
      update_state!
      update_devices_ordering!
      school.refresh_preorder_status!
      notify_other_agents if notify_computacenter && !notifications_sent_by_pool_update?
      true
    end
  end

private

  def notifications_sent_by_pool_update?
    school.in_virtual_cap_pool?
  end

  def notify_other_agents
    device_types = [laptop_cap_changed && :laptop, router_cap_changed && :router].compact
    updates = school.cap_updates(*device_types)
    CapUpdateNotificationsService.new(*updates, notify_school: notify_school).call if updates.any?
  end

  def ordering?(device_type)
    { laptop: laptop_allocation || laptop_cap,
      router: router_allocation || router_cap }[device_type]
  end

  def record_allocation_change_meta_data!(device_type:, school_id:, prev_allocation:, new_allocation:)
    if allocation_change_category || allocation_change_description
      AllocationChange.create!(device_type: device_type,
                               school_id: school_id,
                               category: allocation_change_category,
                               prev_allocation: prev_allocation,
                               new_allocation: new_allocation,
                               description: allocation_change_description)
    end
  end

  def set_device_ordering!(allocation:, cap:, device_type:)
    allocation_field = school.raw_allocation_field(device_type)
    cap_field = school.raw_cap_field(device_type)
    school.write_attribute(allocation_field, allocation) if allocation
    school.update!(cap_field => adjusted_cap_by_order_state(cap, device_type: device_type))
  end

  def update_devices_ordering!
    @laptop_cap_changed = update_ordering!(laptop_allocation, laptop_cap, :laptop) if ordering?(:laptop)
    @router_cap_changed = update_ordering!(router_allocation, router_cap, :router) if ordering?(:router)
  end

  def update_ordering!(allocation, cap, device_type)
    value_changed?(school, :computacenter_cap, device_type) do
      record_allocation_change_meta_data!(device_type: device_type,
                                          school_id: school.id,
                                          prev_allocation: school.raw_allocation(device_type),
                                          new_allocation: allocation)
      set_device_ordering!(allocation: allocation, cap: cap, device_type: device_type)
    end
  end

  def update_state!
    school.update!(order_state: order_state) if update_state?
  end

  def update_state?
    school.order_state != order_state
  end

  def value_changed?(receiver, method, *args)
    initial = receiver.send(method, *args)
    yield
    initial != receiver.send(method, *args)
  end
end
