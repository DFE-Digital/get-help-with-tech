class ResponsibleBody::PooledDeviceCountComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :responsible_body

  def initialize(responsible_body:)
    @responsible_body = responsible_body
  end

  def name_string
    "#{responsible_body.name} has:"
  end

  def availablility_string
    if @responsible_body.has_devices_available_to_order?
      allocations.map { |allocation|
        "#{allocation.available_devices_count} #{allocation.device_type_name.pluralize(allocation.available_devices_count)}"
      }.join(' and <br/>') + ' available to order'
    else
      'All devices ordered'
    end
  end

  def ordered_string
    'You ordered ' + allocations.map { |allocation|
      "#{allocation.devices_ordered} #{allocation.device_type_name.pluralize(allocation.cap)}"
    }.join(' and ')
  end

private

  def allocations
    responsible_body.virtual_cap_pools.order(Arel.sql("device_type = 'coms_device' ASC"))
  end
end
