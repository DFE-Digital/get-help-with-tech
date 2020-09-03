class SchoolWelcomeWizard < ApplicationRecord
  belongs_to :user

  validates :step, presence: true

  enum step: {
    welcome: 'welcome',
    privacy: 'privacy',
    allocation: 'allocation',
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
      complete!
    else
      raise "Unknown step: #{step}"
    end
  end
end
