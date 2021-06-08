class DisplayOrdersComponent < ViewComponent::Base
  attr_reader :school

  def initialize(school:)
    @school = school
  end

  def allocations
    std_devices_count = school.std_device_allocation&.devices_ordered
    coms_devices_count = school.coms_device_allocation&.devices_ordered
    [
      build_text(std_devices_count, 'laptops and tablets'),
      build_text(coms_devices_count, 'router'),
    ]
  end

private

  def build_text(count, name)
    "#{count}&nbsp;#{name.pluralize(count)}"
  end
end
