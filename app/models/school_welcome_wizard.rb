class SchoolWelcomeWizard < ApplicationRecord
  belongs_to :user

  validates :step, presence: true

  enum step: {
    welcome: 'welcome',
    privacy: 'privacy',
    allocation: 'allocation',
    order_your_own: 'order_your_own',
    will_you_order: 'will_you_order',
    techsource_account: 'techsource_account',
    will_other_order: 'will_other_order',
    devices_you_can_order: 'devices_you_can_order',
    complete: 'complete',
  }

  delegate :full_name, :email_address, :telephone, :orders_devices, to: :invited_user

  attr_accessor :invite_user

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
        devices_you_can_order!
      end
    when 'will_you_order'
      if update_will_you_order(params)
        if user_orders_devices?
          techsource_account!
        elsif less_than_3_users_can_order?
          will_other_order!
        else
          devices_you_can_order!
        end
      else
        false
      end
    when 'techsource_account'
      if less_than_3_users_can_order?
        will_other_order!
      else
        devices_you_can_order!
      end
    when 'will_other_order'
      if update_will_other_order(params)
        devices_you_can_order!
      else
        false
      end
    when 'devices_you_can_order'
      complete!
    else
      raise "Unknown step: #{step}"
    end
  end

  def invited_user
    @invited_user ||= find_or_build_invited_user
  end

private

  def find_or_build_invited_user
    if invited_user_id
      User.find(invited_user_id)
    else
      user.school.users.build
    end
  end

  def update_will_you_order(params)
    user_orders_devices = params.fetch(:user_orders_devices, nil)

    if user_orders_devices.nil? || !user_orders_devices.in?(%w[1 0])
      errors.add(:user_orders_devices, I18n.t('will_you_order.errors.choose_option', scope: i18n_scope))
      false
    else
      SchoolWelcomeWizard.transaction do
        update!(user_orders_devices: user_orders_devices)
        user.update!(orders_devices: user_orders_devices)
      end
      true
    end
  end

  def update_will_other_order(params)
    self.invite_user = params.fetch(:invite_user, nil)
    if @invite_user.nil?
      errors.add(:invite_user, I18n.t('will_other_order.errors.will_other_order', scope: i18n_scope))
      false
    elsif @invite_user == 'yes'
      user_attrs = user_params(params)

      @invited_user = user.school.users.build(user_attrs)
      if @invited_user.valid?
        save_and_invite_user!(@invited_user)
      else
        errors.copy!(@invited_user.errors)
        false
      end
    else
      update!(invite_user: 'no')
    end
  end

  def show_will_you_order_section?
    @first_school_user.nil? ? set_first_user_flag! : @first_school_user
  end

  def less_than_3_users_can_order?
    user.school.users.who_can_order_devices.count < 3
  end

  def set_first_user_flag!
    is_first_user_for_school = user.school.users.count == 1
    update!(first_school_user: is_first_user_for_school)
    is_first_user_for_school
  end

  def save_and_invite_user!(new_user)
    SchoolWelcomeWizard.transaction do
      new_user.save!
      self.invited_user_id = new_user.id
      save!
      InviteSchoolUserMailer.with(user: new_user).nominated_contact_email.deliver_later
    end
    true
  end

  def user_params(params)
    params.slice(:full_name, :email_address, :telephone, :orders_devices)
  end

  def i18n_scope
    'page_titles.school_user_welcome_wizard'
  end
end
