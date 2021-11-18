class UpdateSchoolDevicesService
  attr_reader :cap_change_category, :cap_change_description,
              :laptop_allocation, :laptops_ordered, :circumstances_laptops, :over_order_reclaimed_laptops,
              :router_allocation, :routers_ordered, :circumstances_routers, :over_order_reclaimed_routers,
              :notify_computacenter, :notify_school, :order_state,
              :recalculate_vcaps, :school

  DEVICE_TYPES = %i[laptop router].freeze

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
    return unless ordering?(:laptop) || ordering?(:router)

    @laptop_initial_raw_cap = school.raw_cap(:laptop) if ordering?(:laptop)
    @router_initial_raw_cap = school.raw_cap(:router) if ordering?(:router)
    School.transaction do
      update_state!
      update_laptop_allocations! if ordering?(:laptop)
      school.calculate_vcap(:laptop) if recalculate_device_vcap?(:laptop)
      update_router_allocations! if ordering?(:router)
      school.calculate_vcap(:router) if recalculate_device_vcap?(:router)
      school.refresh_preorder_status!
      notify_other_agents if notify_computacenter && !vcaps?
      true
    end
  end

private

  attr_reader :laptop_initial_raw_cap, :router_initial_raw_cap

  def initial_raw_cap(device_type)
    laptop?(device_type) ? laptop_initial_raw_cap : router_initial_raw_cap
  end

  def laptop?(device_type)
    device_type.to_sym == :laptop
  end

  def notify_device?(device_type)
    ordering?(device_type) && initial_raw_cap(device_type) != school.raw_cap(device_type)
  end

  def notify_other_agents
    device_types = DEVICE_TYPES.select { |device_type| notify_device?(device_type) }
    CapUpdateNotificationsService.new(school, device_types: device_types, notify_school: notify_school).call
  end

  def ordering?(device_type)
    @update_devices_ordering ||= {
      laptop: update_state? || laptop_allocation || laptops_ordered || circumstances_laptops || over_order_reclaimed_laptops,
      router: update_state? || router_allocation || routers_ordered || circumstances_routers || over_order_reclaimed_routers,
    }
    @update_devices_ordering[device_type]
  end

  def recalculate_device_vcap?(device_type)
    vcaps? && ordering?(device_type)
  end

  def record_cap_change_meta_data!(device_type)
    if initial_raw_cap(device_type) != school.raw_cap(device_type)
      CapChange.create!(device_type: device_type,
                        school_id: school.id,
                        new_cap: school.raw_cap(device_type),
                        prev_cap: initial_raw_cap(device_type),
                        category: cap_change_category,
                        description: cap_change_description)
    end
  end

  def update_laptop_allocations!
    @laptop_allocation ||= school.raw_allocation(:laptop)
    @laptops_ordered ||= school.raw_devices_ordered(:laptop)
    @circumstances_laptops ||= school.can_order_for_specific_circumstances? ? school.circumstances_devices(:laptop) : 0
    @over_order_reclaimed_laptops ||= school.over_order_reclaimed_devices(:laptop)
    cap = laptops_ordered - (laptop_allocation + circumstances_laptops)
    @over_order_reclaimed_laptops = cap >= 0 ? cap : [[over_order_reclaimed_laptops, 0].min, cap].max
    update_device_ordering!(laptop_allocation, laptops_ordered, circumstances_laptops, over_order_reclaimed_laptops, :laptop)
  end

  def update_router_allocations!
    @router_allocation ||= school.raw_allocation(:router)
    @routers_ordered ||= school.raw_devices_ordered(:router)
    @circumstances_routers ||= school.can_order_for_specific_circumstances? ? school.circumstances_devices(:router) : 0
    @over_order_reclaimed_routers ||= school.over_order_reclaimed_devices(:router)
    cap = routers_ordered - (router_allocation + circumstances_routers)
    @over_order_reclaimed_routers = cap >= 0 ? cap : [[over_order_reclaimed_routers, 0].min, cap].max
    update_device_ordering!(router_allocation, routers_ordered, circumstances_routers, over_order_reclaimed_routers, :router)
  end

  def update_device_ordering!(allocation, devices_ordered, circumstances_devices, over_order_reclaimed_devices, device_type)
    school.update!(school.raw_allocation_field(device_type) => allocation,
                   school.raw_devices_ordered_field(device_type) => devices_ordered,
                   school.circumstances_devices_field(device_type) => circumstances_devices,
                   school.over_order_reclaimed_devices_field(device_type) => over_order_reclaimed_devices)
    record_cap_change_meta_data!(device_type)
  end

  def update_state!
    school.update!(order_state: order_state) if update_state?
  end

  def update_state?
    return @update_state if instance_variable_defined?(:@update_state)

    @update_state = school.order_state.to_sym != order_state.to_sym
  end

  def vcaps?
    recalculate_vcaps && school.vcap?
  end
end
