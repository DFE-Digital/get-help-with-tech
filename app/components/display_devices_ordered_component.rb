class DisplayDevicesOrderedComponent < ViewComponent::Base
  attr_reader :school

  def initialize(school:)
    @school = school
  end

  def devices_ordered
    [
      build_text(school.raw_devices_ordered(:laptop), 'device'),
      build_text(school.raw_devices_ordered(:router), 'router'),
    ]
  end

private

  def build_text(count, name)
    "#{count}&nbsp;#{name.pluralize(count)}"
  end
end
