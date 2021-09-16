class SchoolOrderStateAndCapUpdateService
  include Computacenter::CapChangeNotifier

  attr_accessor :school, :order_state, :caps
  attr_reader :notify_school

  def initialize(school:, order_state:, laptop_cap: nil, router_cap: nil, notify_school: true)
    @school = school
    @order_state = order_state
    @caps = [
      { device_type: 'std_device', cap: laptop_cap },
      { device_type: 'coms_device', cap: router_cap },
    ]
    @notify_school = notify_school
  end

  def call
    update!
  end

  def update!
    update_order_state!(order_state)

    caps.each do |cap|
      allocation = update_cap!(cap[:device_type], cap[:cap])
      # don't send updates as they will happen when the pool is updated and the caps adjusted
      next if responsible_body_has_virtual_caps_enabled? && allocation.in_virtual_cap_pool?

      update_and_notify_computacenter!(allocation)
    end

    # ensure the updates are picked up
    school.reload

    school.refresh_device_ordering_status!

    add_school_to_virtual_cap_pool_if_eligible

    # notifying users should only happen after successful completion of the Computacenter
    # cap update, because it's possible for that to fail and the whole thing
    # is rolled back
    notify_school_by_email(school) if notify_school
  end

private

  def responsible_body_has_virtual_caps_enabled?
    school.responsible_body.has_virtual_cap_feature_flags?
  end

  def update_order_state!(order_state)
    school.update!(order_state: order_state)
  end

  def update_cap!(device_type, cap)
    allocation = SchoolDeviceAllocation.find_or_initialize_by(school_id: school.id, device_type: device_type)
    # we only take the cap from the user if they chose specific circumstances
    # for both other states, we need to infer a new cap from the chosen state
    allocation.cap = allocation.cap_implied_by_order_state(order_state: school.order_state, given_cap: cap)
    allocation.save!
    allocation
  end

  def update_and_notify_computacenter!(allocation)
    if school.can_notify_computacenter? && notify_computacenter_of_cap_changes?
      update_cap_on_computacenter!(allocation.id)
      notify_computacenter_by_email(school, allocation.device_type, allocation.cap)
    end
  end

  def add_school_to_virtual_cap_pool_if_eligible
    return unless school&.orders_managed_centrally?
    return if school.in_virtual_cap_pool?

    begin
      school.responsible_body.add_school_to_virtual_cap_pools!(school)
    rescue VirtualCapPoolError
      Rails.logger.error("Failed to add school to virtual pool (urn: #{school.urn})")
    end
  end
end
