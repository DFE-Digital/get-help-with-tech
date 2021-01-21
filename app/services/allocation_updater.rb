class PhilAllocationUpdater
  def initialize(school:, device_type:, value:)
    @school = school
    @device_type = device_type
    @value = value
  end

  def call
    allocation.update!(allocation: value)

    if cap_will_change?
      cap_service.update!
    end
  end

private

  attr_reader :school, :device_type, :value

  def allocation
    @allocation ||= SchoolDeviceAllocation.find_or_initialize_by(school: school, device_type: device_type)
  end

  def cap_will_change?
    school.can_order?
  end

  def cap_service
    @cap_service ||= PhilSchoolOrderStateAndCapUpdateService.new(
      school: school,
      order_state: school.order_state,
      std_device_cap: new_or_existing_std_device_cap,
      coms_device_cap: new_or_existing_coms_device_cap,
    )
  end

  def new_or_existing_std_device_cap
    allocation.device_type == 'std_device' ? allocation.allocation : SchoolDeviceAllocation.find_or_initialize_by(school: school, device_type: 'std_device').cap
  end

  def new_or_existing_coms_device_cap
    allocation.device_type == 'coms_device' ? allocation.allocation : SchoolDeviceAllocation.find_or_initialize_by(school: school, device_type: 'coms_device').cap
  end
end
