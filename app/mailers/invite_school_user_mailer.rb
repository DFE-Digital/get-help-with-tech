class InviteSchoolUserMailer < ApplicationMailer
  def nominated_contact_email
    @user = params[:user]

    template_mail(
      invite_user_template_id,
      to: @user.email_address,
      personalisation:,
    )
  end

private

  def personalisation
    {
      email_address: @user.email_address,
    }
  end

  def invite_user_template_id
    Settings.govuk_notify.templates.devices.school_nominated_contact
  end
end
