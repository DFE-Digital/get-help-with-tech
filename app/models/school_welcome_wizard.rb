class SchoolWelcomeWizard < ApplicationRecord
  belongs_to :user

  validates :step, presence: true
  validates :orders_devices, inclusion: { in: %w[yes no] }, if: :will_you_order?

  enum step: {
    welcome: 'welcome',
    privacy: 'privacy',
    allocation: 'allocation',
    order_your_own: 'order_your_own',
    will_you_order: 'will_you_order',
    complete: 'complete',
  }

  attr_accessor :orders_devices

  def update_step!(params = {})
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
      if show_will_you_order_section?
        will_you_order!
      else
        complete!
      end
    when 'will_you_order'
      update_will_you_order(params)
      if valid?
        complete!
      else
        false
      end
    else
      raise "Unknown step: #{step}"
    end
  end

private

  def update_will_you_order(params)
    self.orders_devices = params.fetch(:orders_devices, nil)
  end

  def show_will_you_order_section?
    true
  end

  def set_first_user_flag!
    is_first_user_for_school = user.school.users.count == 1
    update!(first_school_user: is_first_user_for_school)
  end
end
