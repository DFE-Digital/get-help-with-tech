class DisplayAllocationsComponent < ViewComponent::Base
  attr_reader :school

  def initialize(school:)
    @school = school
  end

  def allocations
    std_devices_count = school&.std_device_allocation.allocation.to_i
    coms_devices_count = school&.coms_device_allocation.allocation.to_i
    [
      build_text(std_devices_count, 'device'),
      build_text(coms_devices_count, 'router'),
    ]
  end

private

  def build_text(count, name)
    "#{count}&nbsp;#{name.pluralize(count)}"
  end
end
