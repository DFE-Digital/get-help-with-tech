class Support::UserPreviewSummaryListComponent < ViewComponent::Base
  validates :user, presence: true

  def initialize(user:)
    @user = user
  end

  def rows
    r = [
      {
        key: 'Email address',
        value: @user.email_address,
      },
      {
        key: 'Telephone',
        value: @user.telephone,
      },
      {
        key: 'Privacy notice seen',
        value: @user.privacy_notice_seen_at ? l(@user.privacy_notice_seen_at, format: :short) : 'No',
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

    r << { key: 'Deleted', value: 'Yes' } if @user.soft_deleted?
    r
  end

private

  def can_order_devices_label
    if @user.relevant_to_computacenter? && @user.techsource_account_confirmed?
      "Yes, TechSource account confirmed at #{l(@user.techsource_account_confirmed_at, format: :short)}"
    elsif @user.relevant_to_computacenter?
      'No, waiting for TechSource account'
    elsif @user.orders_devices? && !@user.seen_privacy_notice?
      'No, will get a TechSource account once they sign in'
    else
      'No'
    end
  end
end
