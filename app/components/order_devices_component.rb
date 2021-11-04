# frozen_string_literal: true

class OrderDevicesComponent < ViewComponent::Base
  def initialize(organisation:)
    @organisation = organisation
  end

  def before_render
    @order_path = case @organisation
                  when School
                    order_devices_responsible_body_devices_school_path(urn: @organisation.urn)
                  when ResponsibleBody
                    responsible_body_devices_order_devices_path
                  end
  end

  def render?
    case @organisation
    when School
      school_can_order?(@organisation)
    when ResponsibleBody
      responsible_body_can_order?(@organisation)
    else
      false
    end
  end

private

  def school_can_order?(school)
    school.orders_managed_centrally? && (school.devices_ordered(:laptop) < school.cap(:laptop))
  end

  def responsible_body_can_order?(responsible_body)
    responsible_body.has_any_schools_that_can_order_now? && responsible_body.devices_available_to_order?
  end
end
