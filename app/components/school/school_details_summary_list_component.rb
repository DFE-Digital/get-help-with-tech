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
        key: 'Allocation',
        value: pluralize(@school.std_device_allocation&.allocation.to_i, 'device'),
        action_path: devices_guidance_subpage_path(subpage_slug: 'device-allocations', anchor: 'how-to-query-an-allocation'),
        action: 'Query allocation',
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
    return [] if info.nil?

    detail_value = info.will_need_chromebooks.nil? ? 'Not yet known' : t(info.will_need_chromebooks, scope: %i[activerecord attributes preorder_information will_need_chromebooks])
    detail = {
      key: 'Will your school need to order Chromebooks?',
      value: detail_value,
    }

    unless info.orders_managed_centrally?
      detail.merge!({
        change_path: chromebooks_edit_school_path(@school),
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

      unless info.orders_managed_centrally?
        domain.merge!({
          change_path: chromebooks_edit_school_path(@school),
          action: 'Domain',
        })
        recovery.merge!({
          change_path: chromebooks_edit_school_path(@school),
          action: 'Recovery email',
        })
      end
      rows += [domain, recovery]
    end
    rows
  end
end
