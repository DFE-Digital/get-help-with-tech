class Support::SchoolDetailsSummaryListComponent < ResponsibleBody::SchoolDetailsSummaryListComponent
private

  def who_will_order_row
    super.except(:change_path, :action, :action_path)
  end

  def allocation_row
    super.except(:action_path, :action).merge(change_path: support_devices_school_allocation_edit_path(school_urn: @school.urn))
  end

  def order_status_row
    super.except(:action_path, :action).merge(change_path: support_devices_school_enable_orders_path(school_urn: @school.urn))
  end

  def school_contact_row
    super.except(:change_path, :action)
      .tap do |row|
        if @school&.preorder_information&.school_will_be_contacted?
          row.merge!(
            action_path: support_devices_school_invite_path(school_urn: @school.urn),
            action: 'Invite',
          )
        end
      end
  end
end
