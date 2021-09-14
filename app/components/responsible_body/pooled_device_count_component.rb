class ResponsibleBody::PooledDeviceCountComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :responsible_body, :action, :show_action

  def initialize(responsible_body:, show_action: true, action: {})
    @responsible_body = responsible_body
    @action = action
    @show_action = show_action
  end

  def availability_string
    responsible_body.devices_available_to_order? ? devices_available_to_order : 'No devices left to order'
  end

  def name_string
    "#{responsible_body.name} has:"
  end

  def ordered_string
    'You ordered ' + [laptops_ordered, routers_ordered].compact.join(' and ')
  end

private

  def devices_available_to_order
    [laptops_available_to_order, routers_available_to_order].compact.join(' and <br/>') + ' available to order'
  end

  def humanize(noun, number)
    "#{number} #{noun.to_s.pluralize(number)}"
  end

  def laptops_available_to_order
    humanize(:device, responsible_body.laptops_available_to_order) if responsible_body.laptop_pool?
  end

  def laptops_ordered
    humanize(:device, responsible_body.laptops_ordered) if responsible_body.laptop_pool?
  end

  def routers_available_to_order
    humanize(:router, responsible_body.routers_available_to_order) if responsible_body.router_pool?
  end

  def routers_ordered
    humanize(:router, responsible_body.routers_ordered) if responsible_body.router_pool?
  end
end
