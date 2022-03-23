class SchoolUserSummaryListComponent < UserSummaryListComponent
  attr_reader :user, :school

  def initialize(user:, school:)
    @user = user
    @school = school
  end

  def rows
    super.map { |row| changeable_row(row) }
  end

private

  def changeable_row(row)
    row.merge(change_path: edit_school_user_path(school, user), action: user.full_name)
  end
end
