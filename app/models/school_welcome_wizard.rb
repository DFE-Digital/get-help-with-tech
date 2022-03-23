class SchoolWelcomeWizard < ApplicationRecord
  belongs_to :user
  belongs_to :school

  validates :step, presence: true

  enum step: {
    allocation: 'allocation',
    complete: 'complete',
  }

  delegate :full_name, :email_address, :telephone, :orders_devices, to: :invited_user
  delegate :will_need_chromebooks, :school_or_rb_domain, :recovery_email_address, to: :chromebook_information
  attr_accessor :invite_user

  def update_step!(_params = {}, current_step = step)
    force_current_step(current_step)
    complete? || complete!
  end

  def invited_user
    @invited_user ||= school.users.build
  end

  def chromebook_information
    @chromebook_information ||= ChromebookInformationForm.new(
      school: school,
      will_need_chromebooks: school.will_need_chromebooks,
      school_or_rb_domain: school.school_or_rb_domain,
      recovery_email_address: school.recovery_email_address,
    )
  end

private

  def force_current_step(step_name)
    send("#{step_name}!") if step != step_name && SchoolWelcomeWizard.steps.keys.include?(step_name)
  end

  def update_will_other_order(params)
    self.invite_user = params.fetch(:invite_user, nil)
    if @invite_user.nil?
      errors.add(:invite_user, I18n.t('will_other_order.errors.will_other_order', scope: i18n_scope))
      false
    elsif @invite_user == 'yes'
      user_attrs = user_params(params)

      @invited_user = User.new(user_attrs)
      @invited_user.schools << school
      if @invited_user.valid?
        save_and_invite_user!(@invited_user)
        @invited_user = nil
        true
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
      errors.merge!(chromebook_information)
      false
    else
      update_preorder_information!(cb_params)
    end
  end

  def user_orders_devices?
    user.order_devices_for_school?(school)
  end

  def show_chromebooks_form?
    show_chromebooks.nil? ? set_show_chromebooks_flag! : show_chromebooks
  end

  def less_than_can_order_limit?
    school.users.who_can_order_devices.count < User::CAN_ORDER_DEVICES_LIMIT
  end

  def set_show_chromebooks_flag!
    show_page = will_need_chromebooks.nil?
    update!(show_chromebooks: show_page)
    show_page
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
    school.update_chromebook_information_and_status!(params)
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
