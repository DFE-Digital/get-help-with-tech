class InviteExistingUserToResponsibleBodyMailer < ApplicationMailer
  def invite_existing_user_to_responsible_body_email
    @user = params[:user]
    @responsible_body = params[:responsible_body]

    template_mail(
      invite_existing_user_to_responsible_body_template_id,
      to: @user.email_address,
      personalisation:,
    )
  end

private

  def personalisation
    {
      email_address: @user.email_address,
      responsible_body_name: @responsible_body.name,
    }
  end

  def invite_existing_user_to_responsible_body_template_id
    Settings.govuk_notify.templates.devices.invite_existing_user_to_responsible_body
  end
end
