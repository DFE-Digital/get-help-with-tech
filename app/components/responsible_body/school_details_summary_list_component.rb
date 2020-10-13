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
    array << allocation_row
    array << devices_ordered_row if display_devices_ordered_row?
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
    who = (@school.preorder_information || @school.responsible_body).who_will_order_devices_label

    if who.present?
      {
        key: 'Who will order?',
        value: "The #{who.downcase} orders devices",
        change_path: responsible_body_devices_school_change_who_will_order_path(school_urn: @school.urn),
        action: 'who will order',
      }
    else
      {
        key: 'Who will order?',
        value: "#{@school.responsible_body.name} hasn’t decided this yet",
        action_path: responsible_body_devices_who_will_order_edit_path,
        action: 'Decide who will order',
      }
    end
  end

  def allocation_row
    {
      key: 'Provisional allocation',
      value: pluralize(@school.std_device_allocation&.allocation.to_i, 'device'),
      action_path: devices_guidance_subpage_path(subpage_slug: 'device-allocations', anchor: 'how-to-query-an-allocation'),
      action: 'Query allocation',
    }
  end

  def devices_ordered_row
    {
      key: 'Devices ordered',
      value: pluralize(@school.std_device_allocation&.devices_ordered.to_i, 'device'),
    }
  end

  def display_devices_ordered_row?
    @school.std_device_allocation&.devices_ordered.to_i.positive?
  end

  def order_status_row
    if @school.can_order?
      {
        key: 'Can place orders?',
        value: 'Yes, local coronavirus restrictions have been confirmed',
      }
    elsif @school.can_order_for_specific_circumstances?
      {
        key: 'Can place orders?',
        value: 'Yes, for specific circumstances',
      }
    else
      {
        key: 'Can place orders?',
        value: 'Not yet because there are no local coronavirus&nbsp;restrictions'.html_safe,
        action_path: responsible_body_devices_request_devices_path,
        action: 'Request devices for specific circumstances',
      }
    end
  end

  def school_type_row
    {
      key: 'Type of school',
      value: @school.type_label,
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
