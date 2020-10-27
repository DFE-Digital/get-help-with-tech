class Support::SchoolDetailsSummaryListComponent < ResponsibleBody::SchoolDetailsSummaryListComponent
  def rows
    super +
      (headteacher.present? ? [headteacher_row] : [])
  end

private

  def who_will_order_row
    super.except(:change_path, :action, :action_path)
  end

  def allocation_row
    super
      .except(:action_path, :action)
      .merge(
        change_path: support_school_devices_allocation_edit_path(school_urn: @school.urn),
        action: 'allocation',
      )
  end

  def order_status_row
    super
      .except(:action_path, :action)
      .merge(
        change_path: support_school_devices_enable_orders_path(school_urn: @school.urn),
        action: 'whether they can place orders',
      )
  end

  def school_contact_row_if_contact_present
    []
  end

  def headteacher_row
    {
      key: headteacher.title.present? ? headteacher.title.upcase_first : 'Headteacher',
      value: headteacher_lines.map { |line| h(line) }.join('<br>').html_safe,
    }
  end

  def headteacher_lines
    [
      headteacher.full_name,
      headteacher.email_address,
      headteacher.phone_number,
    ].reject(&:blank?)
  end

  def chromebook_rows_if_needed
    super.map { |row| row.except(:change_path, :action, :action_path) }
  end

  def headteacher
    @school.headteacher_contact
  end
end
