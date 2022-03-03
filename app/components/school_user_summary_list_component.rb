class SchoolUserSummaryListComponent < UserSummaryListComponent
  attr_reader :user, :school

  def initialize(user:, school:)
    @user = user
    @school = school
  end

  def rows
    super.map { |row| changeable_row(row) } + [order_devices_row]
  end

private

  def changeable_row(row)
    row.merge(change_path: edit_school_user_path(school, user), action: user.full_name)
  end

  def order_devices
    { key: 'Can order devices?', value: user.orders_devices? ? 'Yes' : 'No' }
  end

  def order_devices_row
    user_eligible_to_order_devices? ? changeable_row(order_devices) : order_devices
  end

  def user_eligible_to_order_devices?
    SchoolPolicy.new(user, school).devices_orderable?
  end
end
