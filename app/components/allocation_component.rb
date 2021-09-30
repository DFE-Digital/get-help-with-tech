# frozen_string_literal: true

class AllocationComponent < ViewComponent::Base
  def initialize(organisation:, devices_left:, routers_left:, devices_ordered:, routers_ordered:, devices_allocation:, routers_allocation:)
    @organisation = organisation
    @devices_left = devices_left
    @routers_left = routers_left
    @devices_ordered = devices_ordered
    @routers_ordered = routers_ordered
    @devices_alloction = devices_allocation
    @routers_allocation = routers_allocation
  end

  def available_to_order_summary
    "#{pluralize(@devices_left, 'device')} and #{pluralize(@routers_left, 'router')} available to order"
  end

  def ordered_summary
    "You've ordered #{@routers_ordered} of #{pluralize(@routers_allocation, 'router')} and #{@devices_ordered} of #{pluralize(@devices_alloction, 'device')}"
  end

end
