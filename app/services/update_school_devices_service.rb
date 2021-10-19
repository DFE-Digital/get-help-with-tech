class UpdateSchoolDevicesService
  attr_reader :allocation_change_category, :allocation_change_description,
              :laptop_allocation, :laptop_cap, :laptops_ordered,
              :router_allocation, :router_cap, :routers_ordered,
              :notify_computacenter, :notify_school, :order_state, :school

  OVER_ORDER_ALLOCATION_CHANGE_CATEGORY = :over_order
  OVER_ORDER_ALLOCATION_CHANGE_DESCRIPTION = 'Over Order'.freeze

  def initialize(school:, notify_school: true, notify_computacenter: true, **opts)
    @allocation_change_category = opts[:allocation_change_category]
    @allocation_change_description = opts[:allocation_change_description]
    @laptop_allocation = opts[:laptop_allocation]
    @laptop_cap = opts[:laptop_cap]
    @laptops_ordered = opts[:laptops_ordered]
    @notify_computacenter = notify_computacenter
    @notify_school = notify_school
    @order_state = (opts[:order_state] || school.order_state).to_s
    @router_allocation = opts[:router_allocation]
    @router_cap = opts[:router_cap]
    @routers_ordered = opts[:routers_ordered]
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
      update_laptop_allocations! if ordering?(:laptop)
      update_router_allocations! if ordering?(:router)
      school.refresh_preorder_status!
      notify_other_agents if notify_computacenter && !notifications_sent_by_pool_update?
      true
    end
  end

private

  attr_reader :laptop_cap_changed, :router_cap_changed

  def allocation_change_props_for(device_type)
    {
      category: allocation_change_category || over_order_category(device_type),
      description: allocation_change_description || over_order_description(device_type)
    }
  end

  def laptop?(device_type)
    device_type.to_sym == :laptop
  end

  def notifications_sent_by_pool_update?
    school.in_virtual_cap_pool?
  end

  def notify_other_agents
    device_types = [laptop_cap_changed && :laptop, router_cap_changed && :router].compact
    updates = school.cap_updates(*device_types)
    CapUpdateNotificationsService.new(*updates, notify_school: notify_school).call if updates.any?
  end

  def ordering?(device_type)
    { laptop: laptop_allocation || laptop_cap || laptops_ordered || school.order_state_previously_changed?,
      router: router_allocation || router_cap || routers_ordered || school.order_state_previously_changed? }[device_type]
  end

  def over_order_category(device_type)
    over_ordered?(device_type) && OVER_ORDER_ALLOCATION_CHANGE_CATEGORY
  end

  def over_order_description(device_type)
    over_ordered?(device_type) && OVER_ORDER_ALLOCATION_CHANGE_DESCRIPTION
  end

  def over_ordered?(device_type)
    over_order(device_type).positive?
  end

  def over_order(device_type)
    if laptop?(device_type)
      @laptop_over_ordered ||= laptops_ordered - laptop_allocation
    else
      @router_over_ordered ||= routers_ordered - router_allocation
    end
  end

  def record_allocation_change_meta_data!(device_type:, school_id:, prev_allocation:, new_allocation:, **opts)
    if opts[:category] || opts[:description]
      AllocationChange.create!(device_type: device_type,
                               school_id: school_id,
                               category: opts[:category],
                               prev_allocation: prev_allocation,
                               new_allocation: new_allocation,
                               description: opts[:description])
    end
  end

  def update_laptop_allocations!
    @laptops_ordered ||= school.raw_devices_ordered(:laptop)
    @laptop_allocation ||= school.raw_allocation(:laptop)
    @laptop_allocation = laptops_ordered if over_ordered?(:laptop)
    @laptop_cap ||= school.raw_cap(:laptop)
    @laptop_cap = laptops_ordered if over_ordered?(:laptop)

    AllocationOverOrderService.new(school, over_order(:laptop), :laptop).call if over_ordered?(:laptop)
    @laptop_cap_changed = update_device_ordering!(laptop_allocation, laptop_cap, laptops_ordered, :laptop)
  end

  def update_router_allocations!
    @routers_ordered ||= school.raw_devices_ordered(:router)
    @router_allocation ||= school.raw_allocation(:router)
    @router_allocation = routers_ordered if over_ordered?(:router)
    @router_cap ||= school.raw_cap(:router)
    @router_cap = routers_ordered if over_ordered?(:router)

    AllocationOverOrderService.new(school, over_order(:router), :router).call if over_ordered?(:router)
    @router_cap_changed = update_device_ordering!(router_allocation, router_cap, routers_ordered, :router)
  end

  def update_device_ordering!(allocation, cap, devices_ordered, device_type)
    value_changed?(school, :computacenter_cap, device_type) do
      record_allocation_change_meta_data!(device_type: device_type,
                                          school_id: school.id,
                                          prev_allocation: school.raw_allocation(device_type),
                                          new_allocation: allocation,
                                          **allocation_change_props_for(device_type))
      update_device_numbers!(allocation, cap, devices_ordered, device_type)
    end
  end

  def update_device_numbers!(allocation, cap, devices_ordered, device_type)
    allocation_field = school.raw_allocation_field(device_type)
    devices_ordered_field = school.raw_devices_ordered_field(device_type)
    cap_field = school.raw_cap_field(device_type)
    school.write_attribute(allocation_field, allocation) if allocation
    school.write_attribute(devices_ordered_field, devices_ordered) if devices_ordered
    school.update!(cap_field => adjusted_cap_by_order_state(cap, device_type: device_type))
  end

  def update_state!
    school.update!(order_state: order_state) if update_state?
  end

  def update_state?
    school.order_state.to_sym != order_state.to_sym
  end

  def value_changed?(receiver, method, *args)
    initial = receiver.send(method, *args)
    yield
    initial != receiver.send(method, *args)
  end
end
