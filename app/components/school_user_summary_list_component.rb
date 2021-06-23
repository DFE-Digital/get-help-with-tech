class SchoolUserSummaryListComponent < UserSummaryListComponent
  def initialize(user:, school:)
    @user = user
    @school = school
  end

  def rows
    info = super
    info += [
      {
        key: 'Has access to the Support Portal',
        value: @user.orders_devices? ? 'Yes' : 'No',
      },
    ]
    info.map do |i|
      i.merge({
        change_path: edit_school_user_path(@school, @user),
        action: @user.full_name,
      })
    end
  end
end
