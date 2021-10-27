class School::SchoolDetailsSummaryListComponent < ViewComponent::Base
  validates :school, presence: true

  def initialize(school:)
    @school = school
  end

  def rows
    array = []
    array << device_allocation_row
    array << router_allocation_row if display_router_allocation_row?
    array << type_of_school_row
    array + chromebook_rows_if_needed
  end

private

  def device_allocation_row
    {
      key: 'Device allocation',
      value: pluralize(@school.raw_allocation(:laptop), 'device'),
    }
  end

  def router_allocation_row
    {
      key: 'Router allocation',
      value: @school.raw_allocation(:router).positive? ? 'routers are available to order' : 'no routers are available to order',
    }
  end

  def display_router_allocation_row?
    @school.raw_allocation(:router).positive?
  end

  def type_of_school_row
    {
      key: 'Setting',
      value: @school.human_for_school_type,
    }
  end

  def chromebook_rows_if_needed
    detail_value = @school.chromebook_info_still_needed? ? 'Not yet known' : t(@school.will_need_chromebooks, scope: %i[activerecord attributes school will_need_chromebooks])
    detail = {
      key: 'Will you need to order Chromebooks?',
      value: detail_value,
    }

    unless @school.orders_managed_centrally?
      detail.merge!({
        change_path: chromebooks_edit_school_path(@school),
        action: 'whether Chromebooks are needed',
      })
    end

    rows = [detail]

    if @school.will_need_chromebooks?
      domain = {
        key: 'Domain',
        value: @school.school_or_rb_domain,
      }
      recovery = {
        key: 'Recovery email',
        value: @school.recovery_email_address,
      }

      unless @school.orders_managed_centrally?
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
