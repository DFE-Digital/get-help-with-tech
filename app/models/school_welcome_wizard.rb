class SchoolWelcomeWizard < ApplicationRecord
  belongs_to :user

  validates :step, presence: true

  enum step: {
    welcome: 'welcome',
    privacy: 'privacy',
    allocation: 'allocation',
    order_your_own: 'order_your_own',
    will_you_order: 'will_you_order',
    complete: 'complete',
  }

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
      if update_will_you_order(params)
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
    user_orders_devices = params.fetch(:orders_devices, nil)

    if user_orders_devices.nil? || !user_orders_devices.in?(%w[1 0])
      errors.add(:orders_devices, I18n.t('page_titles.school_user_welcome_wizard.will_you_order.errors.choose_option'))
      false
    else
      SchoolWelcomeWizard.transaction do
        update!(orders_devices: user_orders_devices)
        user.update!(orders_devices: user_orders_devices)
      end
      true
    end
  end

  def show_will_you_order_section?
    @first_school_user.nil? ? set_first_user_flag! : @first_school_user
  end

  def set_first_user_flag!
    is_first_user_for_school = user.school.users.count == 1
    update!(first_school_user: is_first_user_for_school)
    is_first_user_for_school
  end
end
