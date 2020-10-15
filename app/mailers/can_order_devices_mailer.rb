class CanOrderDevicesMailer < ApplicationMailer
  def user_can_order
    @user = params[:user]
    @school = params[:school]

    tracked_template_mail('can_order',
                          can_order_devices_template_id,
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

private

  def tracked_template_mail(message_type, template_id, mail_params = {})
    EmailAudit.create!(message_type: message_type,
                       template: template_id,
                       email_address: @user.email_address,
                       school_urn: @school.urn)

    template_mail(template_id, mail_params)
  end

  def personalisation
    {
      school: @school.name,
    }
  end

  def nudge_rb_to_add_school_contact_template_id
    Settings.govuk_notify.templates.devices.nudge_rb_to_add_school_contact
  end

  def can_order_devices_template_id
    Settings.govuk_notify.templates.devices.can_order_devices
  end

  def can_order_but_action_needed_template_id
    Settings.govuk_notify.templates.devices.can_order_but_action_needed
  end
end
