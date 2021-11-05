class UpdateSchoolDevicesService
  attr_reader :cap_change_category, :cap_change_description,
              :laptop_allocation, :laptop_cap, :laptops_ordered,
              :router_allocation, :router_cap, :routers_ordered,
              :notify_computacenter, :notify_school, :order_state,
              :recalculate_vcaps, :school

  OVER_ORDER_CAP_CHANGE_CATEGORY = :over_order
  OVER_ORDER_CAP_CHANGE_DESCRIPTION = 'Over Order'.freeze

  def initialize(school:, notify_school: true, notify_computacenter: true, recalculate_vcaps: true, **opts)
    @cap_change_category = opts[:cap_change_category]
    @cap_change_description = opts[:cap_change_description]
    @laptop_allocation = opts[:laptop_allocation]
    @laptop_cap = opts[:laptop_cap]
    @laptops_ordered = opts[:laptops_ordered]
    @notify_computacenter = notify_computacenter
    @notify_school = notify_school
    @order_state = (opts[:order_state] || school.order_state).to_s
    @recalculate_vcaps = recalculate_vcaps
    @router_allocation = opts[:router_allocation]
    @router_cap = opts[:router_cap]
    @routers_ordered = opts[:routers_ordered]
    @school = school
  end

  def call
    return unless allocation_numbers_will_change?

    @laptop_initial_cap = school.cap(:laptop) if laptops_will_change?
    @router_initial_cap = school.cap(:router) if routers_will_change?
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

  attr_reader :laptop_initial_cap, :router_initial_cap

  def allocation_numbers_will_change?
    laptops_will_change? || routers_will_change?
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

  def laptops_will_change?
    update_state? || ordering?(:laptop)
  end

  def notifications_sent_by_pool_update?
    recalculate_vcaps && school.in_virtual_cap_pool?
  end

  def notify_other_agents
    device_types = laptops_will_change? && laptop_initial_cap != school.cap(:laptop) ? %i[laptop] : []
    device_types << :router if routers_will_change? && router_initial_cap != school.cap(:router)
    CapUpdateNotificationsService.new(school, device_types: device_types, notify_school: notify_school).call
  end

  def ordering?(device_type)
    @update_devices_ordering ||= {
      laptop: laptop_allocation || laptop_cap || laptops_ordered,
      router: router_allocation || router_cap || routers_ordered,
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
      @laptop_over_ordered ||= laptops_ordered - [laptop_allocation, laptop_cap].max
    else
      @router_over_ordered ||= routers_ordered - [router_allocation, router_cap].max
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

  def routers_will_change?
    update_state? || ordering?(:router)
  end

  def update_laptop_allocations!
    @laptop_allocation ||= school.raw_allocation(:laptop)
    @laptops_ordered ||= school.raw_devices_ordered(:laptop)
    @laptop_cap ||= school.raw_cap(:laptop)
    @laptop_cap = laptops_ordered if over_ordered?(:laptop)

    AllocationOverOrderService.new(school, over_order(:laptop), :laptop).call if over_ordered?(:laptop)
    update_device_ordering!(laptop_allocation, laptop_cap, laptops_ordered, :laptop)
  end

  def update_router_allocations!
    @router_allocation ||= school.raw_allocation(:router)
    @routers_ordered ||= school.raw_devices_ordered(:router)
    @router_cap ||= school.raw_cap(:router)
    @router_cap = routers_ordered if over_ordered?(:router)

    AllocationOverOrderService.new(school, over_order(:router), :router).call if over_ordered?(:router)
    update_device_ordering!(router_allocation, router_cap, routers_ordered, :router)
  end

  def update_device_ordering!(allocation, cap, devices_ordered, device_type)
    record_cap_change_meta_data!(device_type: device_type,
                                 school_id: school.id,
                                 prev_cap: school.raw_cap(device_type),
                                 new_cap: cap,
                                 **cap_change_props_for(device_type))
    update_device_numbers!(allocation, cap, devices_ordered, device_type)
  end

  def update_device_numbers!(allocation, cap, devices_ordered, device_type)
    school.update!(school.raw_allocation_field(device_type) => allocation,
                   school.raw_devices_ordered_field(device_type) => devices_ordered,
                   school.raw_cap_field(device_type) => cap)
  end

  def update_state!
    school.update!(order_state: order_state) if update_state?
  end

  def update_state?
    return @update_state if instance_variable_defined?(:@update_state)

    @update_state = school.order_state.to_sym != order_state.to_sym
  end
end
