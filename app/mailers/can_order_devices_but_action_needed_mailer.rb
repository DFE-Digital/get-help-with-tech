class CanOrderDevicesButActionNeededMailer < ApplicationMailer
  def notify_user_email
    @user = params[:user]
    @school = params[:school]

    template_mail(
      template_id,
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

  def template_id
    Settings.govuk_notify.templates.devices.can_order_but_action_needed
  end
end
