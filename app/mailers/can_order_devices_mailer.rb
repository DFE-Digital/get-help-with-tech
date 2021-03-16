class CanOrderDevicesMailer < ApplicationMailer
  def user_can_order
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('can_order',
                          can_order_devices_template_id,
                          to: @user.email_address,
                          personalisation: personalisation)
  end

  def user_can_order_in_virtual_cap
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('can_order_in_virtual_cap',
                          can_order_devices_in_virtual_cap_template_id,
                          to: @user.email_address,
                          personalisation: personalisation)
  end

  def user_can_order_in_fe_college
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('can_order_in_fe_college',
                          can_order_devices_in_fe_college_template_id,
                          to: @user.email_address,
                          personalisation: personalisation)
  end

  def user_can_order_routers
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('can_order_routers',
                          can_order_routers_devices_template_id,
                          to: @user.email_address,
                          personalisation: personalisation)
  end

  def user_can_order_routers_in_virtual_cap
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('can_order_routers_in_virtual_cap',
                          can_order_routers_in_virtual_cap_template_id,
                          to: @user.email_address,
                          personalisation: personalisation)
  end

  def user_can_order_routers_in_fe_college
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('can_order_routers_in_fe_college',
                          can_order_routers_in_fe_college_template_id,
                          to: @user.email_address,
                          personalisation: personalisation)
  end

  def user_can_order_but_action_needed
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('can_order_but_action_needed',
                          can_order_but_action_needed_template_id,
                          to: @user.email_address,
                          personalisation: personalisation)
  end

  def nudge_rb_to_add_school_contact
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('nudge_rb_to_add_school_contact',
                          nudge_rb_to_add_school_contact_template_id,
                          to: @user.email_address,
                          personalisation: personalisation)
  end

  def nudge_user_to_read_privacy_policy
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('nudge_user_to_read_privacy_policy',
                          nudge_user_to_read_privacy_policy_template_id,
                          to: @user.email_address,
                          personalisation: personalisation)
  end

  def notify_support_school_can_order_but_no_one_contacted
    @school = params[:school]

    template_mail(notify_support_school_can_order_but_no_one_contacted_template_id,
                  to: 'COVID.TECHNOLOGY@education.gov.uk',
                  personalisation: personalisation)
  end

private

  def tracked_template_mail(message_type, template_id, mail_params = {})
    audit = EmailAudit.create!(message_type: message_type,
                               template: template_id,
                               email_address: @user.email_address,
                               user: @user,
                               school: @school)

    template_mail(template_id, mail_params.merge(reference: audit.id))
  end

  def personalisation
    {
      school: @school.name,
      urn: @school.ukprn_or_urn,
    }
  end

  def nudge_user_to_read_privacy_policy_template_id
    Settings.govuk_notify.templates.devices.nudge_user_to_read_privacy_policy
  end

  def nudge_rb_to_add_school_contact_template_id
    Settings.govuk_notify.templates.devices.nudge_rb_to_add_school_contact
  end

  def can_order_devices_template_id
    Settings.govuk_notify.templates.devices.can_order_devices
  end

  def can_order_devices_in_virtual_cap_template_id
    Settings.govuk_notify.templates.devices.can_order_devices_in_virtual_cap
  end

  def can_order_devices_in_fe_college_template_id
    Settings.govuk_notify.templates.devices.can_order_devices_in_fe_college
  end

  def can_order_but_action_needed_template_id
    Settings.govuk_notify.templates.devices.can_order_but_action_needed
  end

  def notify_support_school_can_order_but_no_one_contacted_template_id
    Settings.govuk_notify.templates.devices.notify_support_school_can_order_but_no_one_contacted
  end

  def can_order_routers_devices_template_id
    Settings.govuk_notify.templates.devices.can_order_routers
  end

  def can_order_routers_in_virtual_cap_template_id
    Settings.govuk_notify.templates.devices.can_order_routers_in_virtual_cap
  end

  def can_order_routers_in_fe_college_template_id
    Settings.govuk_notify.templates.devices.can_order_routers_in_fe_college
  end
end
