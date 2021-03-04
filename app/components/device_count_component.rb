class DeviceCountComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :school, :action, :show_action

  def initialize(school:, show_action: true, they_ordered_prefix: false, action: {})
    @school = school
    @action = action
    @show_action = show_action
    @they_ordered_prefix = they_ordered_prefix
  end

  def availablility_string
    if school.has_devices_available_to_order?
      allocations.map { |allocation|
        "#{allocation.available_devices_count} #{allocation.device_type_name.pluralize(allocation.available_devices_count)}"
      }.join(' and <br/>') + ' available' + availability_suffix
    else
      'All devices ordered'
    end
  end

  def ordered_string
    if school.can_order_for_specific_circumstances? && school.has_ordered?
      'You cannot order your full allocation yet'
    else
      state_prefix + allocations.map { |allocation|
        "#{allocation.devices_ordered} of #{allocation.cap} #{allocation.device_type_name.pluralize(allocation.cap)}"
      }.join(' and ')
    end
  end

  def show_availability?
    !@school.cannot_order_as_reopened?
  end

  def state_prefix
    if @they_ordered_prefix
      'They have ordered '
    elsif @school.cannot_order_as_reopened?
      'You ordered '
    else
      'You’ve ordered '
    end
  end

private

  def availability_suffix
    case school.order_state.to_sym
    when :can_order_for_specific_circumstances
      ' <br/>for specific circumstances'
    else
      ''
    end
  end

  def allocations
    school.device_allocations
  end
end
