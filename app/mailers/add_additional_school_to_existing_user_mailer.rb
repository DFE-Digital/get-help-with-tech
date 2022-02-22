class AddAdditionalSchoolToExistingUserMailer < ApplicationMailer
  def additional_school_email
    @user = params[:user]
    @school = params[:school]

    template_mail(
      additional_school_template_id,
      to: @user.email_address,
      personalisation:,
    )
  end

private

  def personalisation
    {
      email_address: @user.email_address,
      school_name: @school.name,
    }
  end

  def additional_school_template_id
    Settings.govuk_notify.templates.devices.user_added_to_additional_school
  end
end
