class Support::SchoolDetailsSummaryListComponent < ResponsibleBody::SchoolDetailsSummaryListComponent
private

  def who_will_order_row
    super.except(:change_path, :action, :action_path)
  end

  def allocation_row
    super.except(:action_path, :action)
  end

  def order_status_row
    super.except(:action_path, :action)
  end

  def school_contact_row_if_contact_present
    super
      .tap do |rows|
        if rows.present? && @school&.preorder_information&.school_will_be_contacted?
          rows.first.merge!(
            action_path: support_devices_school_invite_path(school_urn: @school.urn),
            action: 'Invite',
          )
        end
      end
  end
end
