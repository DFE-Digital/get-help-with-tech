class UpdateSchoolDevicesService
  attr_reader :cap_change_category, :cap_change_description,
              :laptop_allocation, :laptops_ordered, :circumstances_laptops, :over_order_reclaimed_laptops,
              :router_allocation, :routers_ordered, :circumstances_routers, :over_order_reclaimed_routers,
              :notify_computacenter, :notify_school, :order_state,
              :recalculate_vcaps, :school

  OVER_ORDER_CAP_CHANGE_CATEGORY = :over_order
  OVER_ORDER_CAP_CHANGE_DESCRIPTION = 'Over Order'.freeze

  def initialize(school:, notify_school: true, notify_computacenter: true, recalculate_vcaps: true, **opts)
    @cap_change_category = opts[:cap_change_category]
    @cap_change_description = opts[:cap_change_description]
    @circumstances_laptops = opts[:circumstances_laptops]
    @circumstances_routers = opts[:circumstances_routers]
    @laptop_allocation = opts[:laptop_allocation]
    @laptops_ordered = opts[:laptops_ordered]
    @notify_computacenter = notify_computacenter
    @notify_school = notify_school
    @order_state = (opts[:order_state] || school.order_state).to_s
    @over_order_reclaimed_laptops = opts[:over_order_reclaimed_laptops]
    @over_order_reclaimed_routers = opts[:over_order_reclaimed_routers]
    @recalculate_vcaps = recalculate_vcaps
    @router_allocation = opts[:router_allocation]
    @routers_ordered = opts[:routers_ordered]
    @school = school
  end

  def call
    return unless allocation_numbers_will_change?

    @laptop_initial_raw_cap = school.raw_cap(:laptop) if ordering?(:laptop)
    @router_initial_raw_cap = school.raw_cap(:router) if ordering?(:router)
    School.transaction do
      update_state!
      update_laptop_allocations! if ordering?(:laptop)
      school.calculate_vcaps_if_needed(:laptop) if recalculate_vcaps
      update_router_allocations! if ordering?(:router)
      school.calculate_vcaps_if_needed(:router) if recalculate_vcaps
      school.refresh_preorder_status!
      notify_other_agents if notify_computacenter && !notifications_sent_by_pool_update?
      true
    end
  end

private

  attr_reader :laptop_initial_raw_cap, :router_initial_raw_cap

  def allocation_numbers_will_change?
    update_state? || ordering?(:laptop) || ordering?(:router)
  end

  def cap_change_props_for(device_type)
    {
      category: cap_change_category || over_order_category(device_type),
      description: cap_change_description || over_order_description(device_type),
    }
  end

  def laptop?(device_type)
    device_type.to_sym == :laptop
  end

  def notifications_sent_by_pool_update?
    recalculate_vcaps && school.in_virtual_cap_pool?
  end

  def notify_other_agents
    device_types = (update_state? || ordering?(:laptop)) && laptop_initial_raw_cap != school.raw_cap(:laptop) ? %i[laptop] : []
    device_types << :router if (update_state? || ordering?(:router)) && router_initial_raw_cap != school.raw_cap(:router)
    CapUpdateNotificationsService.new(school, device_types: device_types, notify_school: notify_school).call
  end

  def ordering?(device_type)
    @update_devices_ordering ||= {
      laptop: laptop_allocation || laptops_ordered || circumstances_laptops || over_order_reclaimed_laptops,
      router: router_allocation || routers_ordered || circumstances_routers || over_order_reclaimed_routers,
    }
    @update_devices_ordering[device_type]
  end

  def over_order_category(device_type)
    over_ordered?(device_type) && OVER_ORDER_CAP_CHANGE_CATEGORY
  end

  def over_order_description(device_type)
    over_ordered?(device_type) && OVER_ORDER_CAP_CHANGE_DESCRIPTION
  end

  def over_ordered?(device_type)
    over_order(device_type).positive?
  end

  def over_order(device_type)
    if laptop?(device_type)
      @laptop_over_ordered ||= laptops_ordered - (laptop_allocation + circumstances_laptops + over_order_reclaimed_laptops)
    else
      @router_over_ordered ||= routers_ordered - (router_allocation + circumstances_routers + over_order_reclaimed_routers)
    end
  end

  def record_cap_change_meta_data!(device_type:, school_id:, prev_cap:, new_cap:, **opts)
    if opts[:category] || opts[:description]
      CapChange.create!(device_type: device_type,
                        school_id: school_id,
                        category: opts[:category],
                        prev_cap: prev_cap,
                        new_cap: new_cap,
                        description: opts[:description])
    end
  end

  def update_laptop_allocations!
    @laptop_allocation ||= school.raw_allocation(:laptop)
    @laptops_ordered ||= school.raw_devices_ordered(:laptop)
    @circumstances_laptops ||= school.can_order_for_specific_circumstances? ? school.circumstances_devices(:laptop) : 0
    @over_order_reclaimed_laptops ||= school.over_order_reclaimed_devices(:laptop)
    @over_order_reclaimed_laptops = laptops_ordered - (laptop_allocation + circumstances_laptops) if over_ordered?(:laptop)

    AllocationOverOrderService.new(school, over_order(:laptop), :laptop).call if over_ordered?(:laptop)
    update_device_ordering!(laptop_allocation, laptops_ordered, circumstances_laptops, over_order_reclaimed_laptops, :laptop)
  end

  def update_router_allocations!
    @router_allocation ||= school.raw_allocation(:router)
    @routers_ordered ||= school.raw_devices_ordered(:router)
    @circumstances_routers ||= school.can_order_for_specific_circumstances? ? school.circumstances_devices(:router) : 0
    @over_order_reclaimed_routers ||= school.over_order_reclaimed_devices(:router)
    @over_order_reclaimed_routers = routers_ordered - (router_allocation + circumstances_routers) if over_ordered?(:router)

    AllocationOverOrderService.new(school, over_order(:router), :router).call if over_ordered?(:router)
    update_device_ordering!(router_allocation, routers_ordered, circumstances_routers, over_order_reclaimed_routers, :router)
  end

  def update_device_ordering!(allocation, devices_ordered, circumstances_devices, over_order_reclaimed_devices, device_type)
    prev_raw_cap = school.raw_cap(device_type)
    update_device_numbers!(allocation, devices_ordered, circumstances_devices, over_order_reclaimed_devices, device_type)
    record_cap_change_meta_data!(device_type: device_type,
                                 school_id: school.id,
                                 prev_cap: prev_raw_cap,
                                 new_cap: school.raw_cap(device_type),
                                 **cap_change_props_for(device_type))
  end

  def update_device_numbers!(allocation, devices_ordered, circumstances_devices, over_order_reclaimed_devices, device_type)
    school.update!(school.raw_allocation_field(device_type) => allocation,
                   school.raw_devices_ordered_field(device_type) => devices_ordered,
                   school.circumstances_devices_field(device_type) => circumstances_devices,
                   school.over_order_reclaimed_devices_field(device_type) => over_order_reclaimed_devices)
  end

  def update_state!
    school.update!(order_state: order_state) if update_state?
  end

  def update_state?
    return @update_state if instance_variable_defined?(:@update_state)

    @update_state = school.order_state.to_sym != order_state.to_sym
  end
end
