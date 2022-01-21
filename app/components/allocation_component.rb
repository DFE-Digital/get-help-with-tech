# frozen_string_literal: true

class AllocationComponent < ViewComponent::Base
  attr_reader :organisation, :devices_available, :devices_ordered, :routers_ordered, :devices_allocation, :sane

  def initialize(organisation:, devices_available:, devices_ordered:, routers_ordered:, devices_allocation:)
    @organisation = organisation
    @devices_available = devices_available
    @devices_ordered = devices_ordered
    @routers_ordered = routers_ordered
    @devices_allocation = devices_allocation

    sanity_check
  end

  def available_allocation_sentence
    "Your remaining allocation is currently #{devices_available} #{'device'.pluralize(devices_available)}".html_safe
  end

  def total_allocation_and_devices_ordered_sentence
    "#{organisation.name} has a total allocation of #{devices_allocation} #{'device'.pluralize(devices_allocation)} for academic year 2021/22. You&rsquo;ve ordered #{devices_ordered} #{'device'.pluralize(devices_ordered)} and #{routers_ordered} #{'router'.pluralize(routers_ordered)} in academic year 2021/22".html_safe
  end

  def render?
    sane
  end

  def allocation_and_devices_ordered_sentence
    "#{organisation.name} has a total allocation of #{devices_allocation} #{'device'.pluralize(devices_allocation)} for academic year 2021/22. You&rsquo;ve ordered #{devices_ordered} #{'device'.pluralize(devices_ordered)} and #{routers_ordered} #{'router'.pluralize(routers_ordered)} in academic year 2021/22"
  end

private

  def sanity_check
    @sane = true
    flag_error_to_sentry('Contains negative number') if [devices_available, devices_ordered, routers_ordered, devices_allocation].any?(&:negative?)
  end

  def flag_error_to_sentry(message)
    @sane = false

    Sentry.with_scope do |scope|
      scope.set_context('AllocationComponent.new', { organisation_id: organisation&.id })
      Sentry.capture_message(message)
    end
  end
end
