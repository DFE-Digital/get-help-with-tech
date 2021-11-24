# frozen_string_literal: true

class AllocationComponent < ViewComponent::Base
  def initialize(organisation:, devices_ordered:, routers_ordered:, devices_allocation:)
    @organisation = organisation
    @devices_ordered = devices_ordered
    @routers_ordered = routers_ordered
    @devices_allocation = devices_allocation

    sanity_check
  end

  def render?
    @sane
  end

  def total_allocation_sentence
    "#{@organisation.name} has a total allocation of #{@devices_allocation} #{'device'.pluralize(@devices_allocation)} for academic year 2021/22"
  end

  def ordered_sentence
    "You&rsquo;ve ordered #{@devices_ordered} #{'device'.pluralize(@devices_ordered)} and #{@routers_ordered} #{'router'.pluralize(@routers_ordered)} in academic year 2021/22".html_safe
  end

private

  def sanity_check
    @sane = true
    flag_error_to_sentry('Contains negative number') if [@devices_ordered, @routers_ordered, @devices_allocation].any?(&:negative?)
  end

  def flag_error_to_sentry(message)
    @sane = false

    Sentry.with_scope do |scope|
      scope.set_context('AllocationComponent.new', { organisation_id: @organisation&.id })
      Sentry.capture_message(message)
    end
  end
end
