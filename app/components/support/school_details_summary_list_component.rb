class Support::SchoolDetailsSummaryListComponent < ResponsibleBody::SchoolDetailsSummaryListComponent
  def rows
    array = super
    array.prepend school_name_editable_row if SchoolPolicy.new(viewer, @school).update_name?
    array << headteacher_row if headteacher.present?
    array.map { |row| remove_change_links_if_read_only(row) }
    array << if SchoolPolicy.new(viewer, @school).update_address?
               address_editable_row
             else
               address_read_only_row
             end
    array << sold_to_row
    array << ship_to_row
    array << receiving_communications_row
  end

private

  def sold_to_row
    {
      key: 'Computacenter SoldTo',
      value: @school.responsible_body.computacenter_reference || 'Not present',
    }
  end

  def ship_to_row
    {
      key: 'Computacenter ShipTo',
      value: @school.computacenter_reference || 'Not present',
    }
  end

  def receiving_communications_row
    {
      key: 'Receiving communications',
      value: receiving_communications_value,
      action: 'Change <span class="govuk-visually-hidden">communications preference</span>'.html_safe,
      action_path: edit_support_school_opt_out_path(@school),
    }
  end

  def receiving_communications_value
    if @school.opted_out_of_comms_at
      'No, opted out of receiving communications as they do not want their remaining allocation'
    else
      'Yes, receiving communications'
    end
  end

  def school_name_editable_row
    {
      key: 'Name',
      value: @school.name,
      action: 'Change <span class="govuk-visually-hidden">school name</span>'.html_safe,
      action_path: edit_support_school_path(@school),
    }
  end

  def address_read_only_row
    {
      key: 'Address',
      value: @school.address_components,
    }
  end

  def address_editable_row
    {
      key: 'Address',
      value: @school.address_components,
      action: 'Change <span class="govuk-visually-hidden">address</span>'.html_safe,
      action_path: edit_support_school_addresses_path(school_urn: @school.urn),
    }
  end

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
      key: 'Headteacher',
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
