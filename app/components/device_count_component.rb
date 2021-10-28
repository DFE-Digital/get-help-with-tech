class DeviceCountComponent < ViewComponent::Base
  include ViewHelper

  DEVICE_NAMES = { laptop: 'device', router: 'router' }.freeze

  attr_reader :school, :action, :show_action, :they_ordered_prefix

  def initialize(school:, show_action: true, they_ordered_prefix: false, action: {})
    @school = school
    @action = action
    @show_action = show_action
    @they_ordered_prefix = they_ordered_prefix
  end

  def availability_string
    if school.devices_available_to_order?
      devices_remaining = school.devices_available_to_order('laptop')
      "#{pluralize(devices_remaining, 'device is', plural: 'devices are')} available to order" + availability_suffix
    else
      'All devices ordered'
    end
  end

  def ordered_string
    if school.can_order_for_specific_circumstances? && school.has_ordered?
      'You cannot order your full allocation yet'
    else
      state_prefix + non_zero_caps.map { |device_type|
        "#{school.devices_ordered(device_type)} of #{school.cap(device_type)} #{DEVICE_NAMES[device_type].pluralize(school.cap(device_type))}"
      }.join(' and ')
    end
  end

  def state_prefix
    they_ordered_prefix ? 'They have ordered ' : 'You’ve ordered '
  end

private

  def availability_suffix
    school.order_state.to_sym == :can_order_for_specific_circumstances ? ' <br/>for specific circumstances.' : '.'
  end

  def non_zero_caps
    %i[laptop router].reject { |device_type| school.cap(device_type).zero? }
  end
end
