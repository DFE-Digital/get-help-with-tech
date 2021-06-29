class DisplayDevicesOrderedComponent < ViewComponent::Base
  attr_reader :school

  def initialize(school:)
    @school = school
  end

  def devices_ordered
    std_devices_count = school.std_device_allocation&.raw_devices_ordered || 0
    coms_devices_count = school.coms_device_allocation&.raw_devices_ordered || 0
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
