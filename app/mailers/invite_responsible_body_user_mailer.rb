class InviteResponsibleBodyUserMailer < ApplicationMailer
  def invite_user_email
    @user = params[:user]
    @rb = @user.responsible_body

    template_mail(
      invite_user_template_id,
      to: @user.email_address,
      personalisation: personalisation,
    )
  end

private

  def personalisation
    {
      email_address: @user.email_address,
      responsible_body_name: rb_name,
    }
  end

  def rb_name
    @rb.local_authority_official_name || @rb.name
  end

  def invite_user_template_id
    Settings.govuk_notify.templates.devices.invite_responsible_body_user
  end
end
