class UserSummaryListComponent < ViewComponent::Base
  validates :user, presence: true

  def initialize(user:)
    @user = user
  end

  def rows
    [
      {
        key: 'Email address',
        value: @user.email_address,
      },
      {
        key: 'Telephone',
        value: @user.telephone,
      },
      {
        key: 'Last sign-in',
        value: @user.last_signed_in_at ? l(@user.last_signed_in_at, format: :short) : 'Never',
      },
    ]
  end
end
