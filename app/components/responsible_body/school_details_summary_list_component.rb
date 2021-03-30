class ResponsibleBody::SchoolDetailsSummaryListComponent < ViewComponent::Base
  include ViewHelper
  validates :school, presence: true

  delegate :school_will_order_devices?,
           :school_contact,
           to: :preorder_information,
           allow_nil: true

  def initialize(school:, viewer: nil)
    @school = school
    @viewer = viewer
  end

  def rows
    array = []
    array << preorder_status_row
    array << who_will_order_row
    array << device_allocation_row
    array << devices_ordered_row if display_devices_ordered_row?
    array << router_allocation_row if display_router_allocation_row?
    array << routers_ordered_row if display_routers_ordered_row?
    array << order_status_row
    array << school_type_row

    array +
      school_contact_row_if_contact_present +
      chromebook_rows_if_needed
  end

private

  attr_reader :viewer

  def preorder_status_row
    {
      key: 'Status',
      value: render(SchoolPreorderStatusTagComponent.new(school: @school, viewer: viewer)),
    }
  end

  def who_will_order_row
    responsible_body = @school.responsible_body
    who = (@school.preorder_information || responsible_body).who_will_order_devices_label

    if who.present?
      detail = {
        key: 'Who will order?',
        value: "The #{who.downcase} orders devices",
        action: 'who will order',
      }

      if @school.preorder_information&.can_change_who_will_order_devices?
        detail.merge!(
          change_path: responsible_body_devices_school_change_who_will_order_path(school_urn: @school.urn),
        )
      end
      detail
    else
      {
        key: 'Who will order?',
        value: "#{responsible_body.name} hasn’t decided this yet",
        action_path: responsible_body_devices_who_will_order_edit_path,
        action: 'Decide who will order',
      }
    end
  end

  def device_allocation_row
    allocation = @school.std_device_allocation&.raw_allocation.to_i
    {
      key: 'Device allocation',
      value: pluralize(allocation, 'device'),
      action_path: devices_guidance_subpage_path(subpage_slug: 'device-allocations', anchor: 'how-to-query-an-allocation'),
      action: 'Query <span class="govuk-visually-hidden">device</span> allocation'.html_safe,
    }
  end

  def router_allocation_row
    allocation = @school.coms_device_allocation&.raw_allocation.to_i
    {
      key: 'Router allocation',
      value: pluralize(allocation, 'router'),
      action_path: devices_guidance_subpage_path(subpage_slug: 'device-allocations', anchor: 'how-to-query-an-allocation'),
      action: 'Query <span class="govuk-visually-hidden">router</span> allocation'.html_safe,
    }
  end

  def devices_ordered_row
    {
      key: 'Devices ordered',
      value: pluralize(@school.std_device_allocation&.devices_ordered.to_i, 'device'),
    }
  end

  def routers_ordered_row
    {
      key: 'Routers ordered',
      value: pluralize(@school.coms_device_allocation&.devices_ordered.to_i, 'router'),
    }
  end

  def display_devices_ordered_row?
    (!@school.responsible_body.has_virtual_cap_feature_flags? || !@school.in_virtual_cap_pool?) && @school.std_device_allocation&.devices_ordered.to_i.positive?
  end

  def display_routers_ordered_row?
    (!@school.responsible_body.has_virtual_cap_feature_flags? || !@school.in_virtual_cap_pool?) && @school.coms_device_allocation&.devices_ordered.to_i.positive?
  end

  def display_router_allocation_row?
    @school.coms_device_allocation&.raw_allocation.to_i.positive?
  end

  def order_status_row
    if @school.can_order?
      {
        key: 'Can place orders?',
        value: 'Yes, a closure or group of self-isolating children has been reported',
      }
    elsif @school.can_order_for_specific_circumstances?
      {
        key: 'Can place orders?',
        value: 'Yes, for specific circumstances',
      }
    else
      {
        key: 'Can place orders?',
        value: 'Not yet because no closure or group of self-isolating children has been reported'.html_safe,
      }
    end
  end

  def school_type_row
    {
      key: 'Setting',
      value: @school.human_for_school_type,
    }
  end

  def school_contact_row_if_contact_present
    if school_will_order_devices? && school_contact.present?
      [school_contact_row]
    else
      []
    end
  end

  def school_contact_row
    {
      key: 'School contact',
      value: contact_lines.map { |line| h(line) }.join('<br>').html_safe,
      change_path: responsible_body_devices_school_who_to_contact_edit_path(school_urn: @school.urn),
      action: 'Change',
    }
  end

  def contact_lines
    [
      school_contact.title.present? ? "#{school_contact.title.upcase_first}: #{school_contact.full_name}" : school_contact.full_name,
      school_contact.email_address,
      school_contact.phone_number,
    ].reject(&:blank?)
  end

  def preorder_information
    @school.preorder_information
  end

  def chromebook_rows_if_needed
    info = @school.preorder_information
    return [] if info.nil?

    detail_value = info.will_need_chromebooks.nil? ? 'Not yet known' : t(info.will_need_chromebooks, scope: %i[activerecord attributes preorder_information will_need_chromebooks])
    detail = {
      key: 'Ordering Chromebooks?',
      value: detail_value,
    }

    if info.orders_managed_centrally?
      change_path = responsible_body_devices_school_chromebooks_edit_path(school_urn: @school.urn)
      detail.merge!({
        change_path: change_path,
        action: 'whether Chromebooks are needed',
      })
    end

    rows = [detail]

    if info.will_need_chromebooks?
      domain = {
        key: 'Domain',
        value: info.school_or_rb_domain,
      }
      recovery = {
        key: 'Recovery email',
        value: info.recovery_email_address,
      }

      if info.orders_managed_centrally?
        domain.merge!({
          change_path: change_path,
          action: 'domain',
        })
        recovery.merge!({
          change_path: change_path,
          action: 'recovery email',
        })
      end
      rows += [domain, recovery]
    end
    rows
  end
end
