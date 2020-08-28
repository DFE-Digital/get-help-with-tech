class SchoolDetailsSummaryListComponent < ViewComponent::Base
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
        key: 'Provisional allocation',
        value: pluralize(@school.std_device_allocation&.allocation.to_i, 'device'),
        action_path: devices_guidance_subpage_path(subpage_slug: 'device-allocations', anchor: 'how-to-query-an-allocation'),
        action: 'Query allocation',
      },
      {
        key: 'Type of school',
        value: @school.type_label,
      },
      {
        key: 'Who will order?',
        value: "The #{(@school.preorder_information || @school.responsible_body).who_will_order_devices_label.downcase} orders devices",
        change_path: responsible_body_devices_school_change_who_will_order_path(school_urn: @school.urn),
        action: 'who will order',
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
    if info&.needs_chromebook_information?
      change_path = responsible_body_devices_school_chromebooks_edit_path(school_urn: @school.urn)
      rows = [
        info.will_need_chromebooks && {
          key: 'Ordering Chromebooks?',
          value: t(info.will_need_chromebooks, scope: %i[activerecord attributes preorder_information will_need_chromebooks]),
          change_path: change_path,
          action: 'whether Chromebooks are needed',
        },
      ]
      if info.will_need_chromebooks?
        rows += [
          info.school_or_rb_domain && {
            key: 'Domain',
            value: info.school_or_rb_domain,
            change_path: change_path,
            action: 'Domain',
          },
          info.recovery_email_address && {
            key: 'Recovery email',
            value: info.recovery_email_address,
            change_path: change_path,
            action: 'Recovery email',
          },
        ]
      end
      rows.compact
    else
      []
    end
  end
end
