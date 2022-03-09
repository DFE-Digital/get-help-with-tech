# frozen_string_literal: true

class AllocationComponent < ViewComponent::Base
  attr_reader :organisation, :devices_available, :devices_ordered, :routers_ordered, :devices_allocation, :sane

  def initialize(organisation:, devices_available:, devices_ordered:, routers_ordered:, devices_allocation:)
    @organisation = organisation
    @devices_available = devices_available
    @devices_ordered = devices_ordered
    @routers_ordered = routers_ordered
    @devices_allocation = devices_allocation
  end

  def ordering_closed_sentence
    'Ordering is now closed'
  end

  def devices_ordered_sentence
    "#{organisation.name} ordered #{devices_ordered} #{'device'.pluralize(devices_ordered)} and #{routers_ordered} #{'router'.pluralize(routers_ordered)} in academic year 2021/22.".html_safe
  end
end
