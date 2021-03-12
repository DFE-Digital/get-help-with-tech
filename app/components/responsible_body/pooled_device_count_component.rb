class ResponsibleBody::PooledDeviceCountComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :responsible_body, :action, :show_action

  def initialize(responsible_body:, show_action: true, action: {})
    @responsible_body = responsible_body
    @action = action
    @show_action = show_action
  end

  def name_string
    "#{responsible_body.name} has:"
  end

  def availability_string
    if @responsible_body.has_devices_available_to_order?
      allocations.map { |allocation|
        "#{allocation.available_devices_count} #{allocation.device_type_name.pluralize(allocation.available_devices_count)}"
      }.join(' and <br/>') + ' available to order'
    else
      'No devices left to order'
    end
  end

  def ordered_string
    'You ordered ' + allocations.map { |allocation|
      "#{allocation.devices_ordered} #{allocation.device_type_name.pluralize(allocation.cap)}"
    }.join(' and ')
  end

private

  def allocations
    responsible_body.virtual_cap_pools.with_std_device_first
  end
end
