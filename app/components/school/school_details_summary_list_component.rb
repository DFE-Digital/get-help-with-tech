class School::SchoolDetailsSummaryListComponent < ViewComponent::Base
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
        key: 'Provisional allocation',
        value: pluralize(@school.std_device_allocation&.allocation.to_i, 'device'),
      },
      {
        key: 'Type of school',
        value: @school.type_label,
      },
    ] + chromebook_rows_if_needed
  end

private

  def preorder_information
    @school.preorder_information
  end

  def chromebook_rows_if_needed
    info = @school.preorder_information
    if info&.needs_chromebook_information?
      rows = [
        info.will_need_chromebooks && {
          key: 'Will your school need to order Chromebooks?',
          value: t(info.will_need_chromebooks, scope: %i[activerecord attributes preorder_information will_need_chromebooks]),
        },
      ]
      if info.will_need_chromebooks?
        rows += [
          info.school_or_rb_domain && {
            key: 'Domain',
            value: info.school_or_rb_domain,
          },
          info.recovery_email_address && {
            key: 'Recovery email',
            value: info.recovery_email_address,
          },
        ]
      end
      rows.compact
    else
      []
    end
  end
end
