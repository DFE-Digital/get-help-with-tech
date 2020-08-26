class InviteResponsibleBodyUserMailer < ApplicationMailer
  def invite_user_email
    @user = params[:user]
    rb_name = @user.responsible_body.local_authority_official_name || @user.responsible_body.name
    personalisation = {
      email_address: @user.email_address,
      responsible_body_name: rb_name,
    }

    template_mail(
      notify_template_id,
      to: @user.email_address,
      personalisation: personalisation,
    )
  end

private

  def notify_template_id
    Settings.govuk_notify.templates.devices.invite_responsible_body_user
  end
end
