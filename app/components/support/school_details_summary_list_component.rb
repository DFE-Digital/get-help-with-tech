class Support::SchoolDetailsSummaryListComponent < ResponsibleBody::SchoolDetailsSummaryListComponent
  def rows
    array = super
    array << headteacher_row if headteacher.present?
    array.map { |row| remove_change_links_if_read_only(row) }
    array << { key: 'Address', value: @school.address_components }
  end

private

  def who_will_order_row
    super.except(:change_path, :action, :action_path)
  end

  def device_allocation_row
    super
      .except(:action_path, :action)
      .merge(
        change_path: support_school_devices_allocation_edit_path(school_urn: @school.urn),
        action: 'allocation',
      )
  end

  def router_allocation_row
    super
      .except(:action_path, :action)
      .merge(
        change_path: support_school_devices_allocation_edit_path(school_urn: @school.urn, device_type: 'coms_device'),
        action: 'router allocation',
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
    super.map do |row|
      row
        .except(:change_path, :action, :action_path)
        .merge(
          change_path: support_school_devices_chromebooks_edit_path(school_urn: @school.urn),
        )
    end
  end

  def headteacher
    @school.headteacher_contact
  end

  def display_router_allocation_row?
    true
  end

  def remove_change_links_if_read_only(row)
    if row.in?(chromebook_rows_if_needed) && Pundit.policy(viewer, :chromebook).edit?
      row
    elsif Pundit.policy(viewer, @school).edit?
      row
    else
      row.except(:change_path, :action, :action_path)
    end
  end
end
