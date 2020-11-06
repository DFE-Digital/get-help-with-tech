class AllocationUpdater
  def initialize(school:, device_type:, value:)
    @school = school
    @device_type = device_type
    @value = value
  end

  def call
    allocation.update!(allocation: value, cap: cap)
  end

private

  attr_reader :school, :device_type, :value

  def allocation
    @allocation ||= SchoolDeviceAllocation.find_or_initialize_by(school: school, device_type: device_type)
  end

  def cap
    if school.can_order?
      value
    else
      allocation.cap
    end
  end
end
