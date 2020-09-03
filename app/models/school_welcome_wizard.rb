class SchoolWelcomeWizard < ApplicationRecord
  belongs_to :user

  validates :step, presence: true

  enum step: {
    welcome: 'welcome',
    privacy: 'privacy',
    allocation: 'allocation',
    order_your_own: 'order_your_own',
    complete: 'complete',
  }

  def update_step!(_params = {})
    return true if complete?

    case step
    when 'welcome'
      privacy!
    when 'privacy'
      user.seen_privacy_notice!
      allocation!
    when 'allocation'
      order_your_own!
    when 'order_your_own'
      complete!
    else
      raise "Unknown step: #{step}"
    end
  end
end
