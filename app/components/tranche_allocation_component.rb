# frozen_string_literal: true

class TrancheAllocationComponent < ViewComponent::Base
  def initialize(organisation:, devices_remaining:, routers_remaining:, devices_ordered:, routers_ordered:, devices_allocation:, routers_allocation:)
    @organisation = organisation
    @devices_remaining = devices_remaining
    @routers_remaining = routers_remaining
    @devices_ordered = devices_ordered
    @routers_ordered = routers_ordered
    @devices_allocation = devices_allocation
    @routers_allocation = routers_allocation

    sanity_check
  end

  def render?
    @sane
  end

  def intro_sentence
    if @organisation.is_a?(ResponsibleBody)
      "#{@organisation.name} has:"
    else
      raise 'Invalid for school'
    end
  end

  def available_to_order_summary
    "#{pluralize(@devices_remaining, 'device')} and "\
    "#{pluralize(@routers_remaining, 'router')} available to order"
  end

  def ordered_summary
    "You&rsquo;ve ordered #{@devices_ordered} of #{pluralize(@devices_allocation, 'device')} and "\
    "#{@routers_ordered} of #{pluralize(@routers_allocation, 'router')}".html_safe
  end

private

  def sanity_check
    @sane = true
    flag_error_to_sentry('Contains negative number') if [@devices_remaining, @routers_remaining, @devices_ordered, @routers_ordered, @devices_allocation, @routers_allocation].any?(&:negative?)
    flag_allocation_if_necessary(allocation: @devices_allocation, ordered: @devices_ordered, remaining: @devices_remaining)
    flag_allocation_if_necessary(allocation: @routers_allocation, ordered: @routers_ordered, remaining: @routers_remaining)
  end

  def flag_error_to_sentry(message)
    @sane = false

    Sentry.with_scope do |scope|
      scope.set_context('TrancheAllocationComponent.new', { organisation_id: @organisation&.id })
      Sentry.capture_message(message)
    end
  end

  def flag_allocation_if_necessary(allocation:, ordered:, remaining:)
    flag_error_to_sentry(summation_error_message(allocation: allocation, ordered: ordered, remaining: remaining)) unless allocation == ordered + remaining
  end

  def summation_error_message(allocation:, ordered:, remaining:)
    "Expected allocation == ordered + remaining, but #{allocation} != #{ordered} + #{remaining}"
  end
end
