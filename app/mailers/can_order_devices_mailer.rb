class CanOrderDevicesMailer < ApplicationMailer
  def user_can_order
    @user = params[:user]
    @school = params[:school]

    template_mail(
      can_order_devices_template_id,
      to: @user.email_address,
      personalisation: personalisation,
    )
  end

  def user_can_order_but_action_needed
    @user = params[:user]
    @school = params[:school]

    template_mail(
      can_order_but_action_needed_template_id,
      to: @user.email_address,
      personalisation: personalisation,
    )
  end

private

  def personalisation
    {
      school: @school.name,
    }
  end

  def can_order_devices_template_id
    Settings.govuk_notify.templates.devices.can_order_devices
  end

  def can_order_but_action_needed_template_id
    Settings.govuk_notify.templates.devices.can_order_but_action_needed
  end
end
