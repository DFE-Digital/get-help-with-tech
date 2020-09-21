class SchoolUserSummaryListComponent < UserSummaryListComponent
  def rows
    info = super
    info += [
      {
        key: 'Orders devices',
        value: @user.orders_devices? ? 'Yes' : 'No',
      },
    ]
    info.map do |i|
      i.merge({
        change_path: edit_school_user_path(@user),
        action: @user.full_name,
      })
    end
  end
end
