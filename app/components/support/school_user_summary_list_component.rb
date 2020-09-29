class Support::SchoolUserSummaryListComponent < ViewComponent::Base
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
        key: 'Last sign in',
        value: @user.last_signed_in_at ? l(@user.last_signed_in_at, format: :short) : 'Never',
      },
      {
        key: 'Sign in count',
        value: @user.sign_in_count,
      },
      {
        key: 'Can order devices?',
        value: can_order_devices_label,
      },
    ]
  end

private

  def can_order_devices_label
    if @user.relevant_to_computacenter? && @user.techsource_account_confirmed?
      'Yes, TechSource account confirmed'
    elsif @user.relevant_to_computacenter?
      'No, waiting for TechSource account'
    elsif @user.orders_devices? && !@user.seen_privacy_notice?
      'No, will get a TechSource account once they sign in'
    else
      'No'
    end
  end
end
