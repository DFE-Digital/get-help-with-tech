class AllocationUpdater
  def initialize(school:, device_type:, value:, category: nil, description: nil)
    @school = school
    @device_type = device_type
    @value = value
    @category = category
    @description = description
    @delta = delta
    @prev_allocation = prev_allocation
  end

  def call
    SchoolDeviceAllocation.transaction do
      record_allocation_change_meta_data unless @category.nil? && @description.nil?

      # HACK: this is a tactical fix to allow allocations to be decreased - we need to attempt to
      # update the cap to keep the allocation record valid when persisting the change.
      # We want to still keep the previous behaviour for increases.
      if decreasing?
        allocation.update!(allocation: value, cap: adjusted_cap_when_decreasing)
      else
        allocation.update!(allocation: value)
      end

      if cap_will_change?
        cap_service.update!
      end
    end
  end

private

  attr_reader :school, :device_type, :value, :category

  def allocation
    @allocation ||= SchoolDeviceAllocation.find_or_initialize_by(school: school, device_type: device_type)
  end

  def decreasing?
    value < allocation.raw_allocation
  end

  def adjusted_cap_when_decreasing
    # This mirrors the logic in the `SchoolAllocationDevice#cap_implied_by_order_state` method,
    # which is used in the cap_service below.
    # We can't call that method directly as it relies on the internal state of the allocation
    # object which won't have been updated just yet (chicken and egg!)
    case school.order_state.to_sym
    when :cannot_order
      allocation.raw_devices_ordered.to_i
    when :can_order
      value
    else
      allocation.raw_cap
    end
  end

  def cap_will_change?
    school.can_order?
  end

  def cap_service
    @cap_service ||= SchoolOrderStateAndCapUpdateService.new(
      school: school,
      order_state: school.order_state,
      laptop_cap: new_or_existing_std_device_cap,
      router_cap: new_or_existing_coms_device_cap,
    )
  end

  def new_or_existing_std_device_cap
    allocation.device_type == 'std_device' ? allocation.allocation : SchoolDeviceAllocation.find_or_initialize_by(school: school, device_type: 'std_device').cap
  end

  def new_or_existing_coms_device_cap
    allocation.device_type == 'coms_device' ? allocation.allocation : SchoolDeviceAllocation.find_or_initialize_by(school: school, device_type: 'coms_device').cap
  end

  def record_allocation_change_meta_data
    AllocationChange.create!(school_device_allocation: allocation,
                             category: @category,
                             delta: delta,
                             prev_allocation: prev_allocation,
                             new_allocation: @value,
                             description: @description)
  end

  def delta
    @delta ||= allocation.raw_allocation - value
  end

  def prev_allocation
    @prev_allocation ||= allocation.raw_allocation
  end
end
