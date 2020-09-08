class ResponsibleBody::SchoolDetailsSummaryListComponent < ViewComponent::Base
  include ViewHelper
  validates :school, presence: true

  delegate :school_will_order_devices?,
           :school_contact,
           to: :preorder_information

  def initialize(school:)
    @school = school
  end

  def rows
    [
      {
        key: 'Status',
        value: render(SchoolPreorderStatusTagComponent.new(school: @school)),
      },
      {
        key: 'Who will order?',
        value: "The #{(@school.preorder_information || @school.responsible_body).who_will_order_devices_label.downcase} orders devices",
        change_path: responsible_body_devices_school_change_who_will_order_path(school_urn: @school.urn),
        action: 'who will order',
      },
      {
        key: 'Provisional allocation',
        value: pluralize(@school.std_device_allocation&.allocation.to_i, 'device'),
        action_path: devices_guidance_subpage_path(subpage_slug: 'device-allocations', anchor: 'how-to-query-an-allocation'),
        action: 'Query allocation',
      },
      {
        key: 'Can place orders?',
        value: ['Not yet because there are no local coronavirus restrictions', govuk_link_to('Get devices early for specific circumstances', responsible_body_devices_request_devices_path)].join('<br>').html_safe,
      },
      {
        key: 'Type of school',
        value: @school.type_label,
      },
    ] + school_contact_row_if_contact_present + chromebook_rows_if_needed
  end

private

  def school_contact_row_if_contact_present
    if school_will_order_devices? && school_contact.present?
      [{
        key: 'School contact',
        value: contact_lines.map { |line| h(line) }.join('<br>').html_safe,
      }]
    else
      []
    end
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
          action: 'Domain',
        })
        recovery.merge!({
          change_path: change_path,
          action: 'Recovery email',
        })
      end
      rows += [domain, recovery]
    end
    rows
  end
end
