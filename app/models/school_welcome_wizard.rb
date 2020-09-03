class SchoolWelcomeWizard < ApplicationRecord
  belongs_to :user

  validates :step, presence: true

  enum step: {
    welcome: 'welcome',
    privacy: 'privacy',
    complete: 'complete',
  }

  def update_step!(_params = {})
    case step
    when 'welcome'
      privacy!
    when 'privacy'
      user.seen_privacy_notice!
      complete!
    else
      raise "Unknown step: #{step}"
    end
  end
end
