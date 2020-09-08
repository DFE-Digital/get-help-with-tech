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
    chromebooks: 'chromebooks',
    what_happens_next: 'what_happens_next',
    complete: 'complete',
  }

  delegate :school, to: :user
  delegate :full_name, :email_address, :telephone, :orders_devices, to: :invited_user
  delegate :will_need_chromebooks, :school_or_rb_domain, :recovery_email_address, to: :chromebook_information
  attr_accessor :invite_user

  def update_step!(params = {})
    return true if complete?

    case step
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
      if will_need_chromebooks.nil?
        chromebooks!
      else
        what_happens_next!
      end
    when 'chromebooks'
      if update_chromebooks(params)
        what_happens_next!
      else
        false
      end
    when 'what_happens_next'
      complete!
    else
      raise "Unknown step: #{step}"
    end
  end

  def invited_user
    @invited_user ||= find_or_build_invited_user
  end

  def chromebook_information
    @chromebook_information ||= ChromebookInformationForm.new(
      school: school,
      will_need_chromebooks: school.preorder_information&.will_need_chromebooks,
      school_or_rb_domain: school.preorder_information&.school_or_rb_domain,
      recovery_email_address: school.preorder_information&.recovery_email_address,
    )
  end

private

  def find_or_build_invited_user
    if invited_user_id
      User.find(invited_user_id)
    else
      school.users.build
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

      @invited_user = school.users.build(user_attrs)
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

  def update_chromebooks(params)
    cb_params = chromebook_params(params)
    chromebook_information.assign_attributes(cb_params)

    if will_need_chromebooks.nil?
      errors.add(:will_need_chromebooks, I18n.t('chromebooks.errors.choice', scope: i18n_scope))
      false
    elsif chromebook_information.invalid?
      errors.copy!(chromebook_information.errors)
      false
    else
      update_preorder_information!(cb_params)
    end
  end

  def show_will_you_order_section?
    @first_school_user.nil? ? set_first_user_flag! : @first_school_user
  end

  def less_than_3_users_can_order?
    school.users.who_can_order_devices.count < 3
  end

  def set_first_user_flag!
    is_first_user_for_school = school.users.count == 1
    update!(first_school_user: is_first_user_for_school)
    is_first_user_for_school
  end

  def save_and_invite_user!(new_user)
    SchoolWelcomeWizard.transaction do
      new_user.save!
      update!(invited_user_id: new_user.id)
      InviteSchoolUserMailer.with(user: new_user).nominated_contact_email.deliver_later
    end
    true
  end

  def update_preorder_information!(params)
    params[:will_need_chromebooks] = nil if params[:will_need_chromebooks] == 'i_dont_know'
    school.preorder_information.update_chromebook_information_and_status!(params)
  end

  def user_params(params)
    params.slice(:full_name, :email_address, :telephone, :orders_devices)
  end

  def chromebook_params(params)
    params.slice(:will_need_chromebooks, :school_or_rb_domain, :recovery_email_address)
  end

  def i18n_scope
    'page_titles.school_user_welcome_wizard'
  end
end
