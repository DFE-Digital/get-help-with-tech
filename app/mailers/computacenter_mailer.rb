class ComputacenterMailer < ApplicationMailer
  def notify_of_devices_cap_change
    setup_params

    template_mail(
      devices_cap_change_template_id,
      to: recipient,
      personalisation: personalisation,
    )
  end

  def notify_of_comms_cap_change
    setup_params

    template_mail(
      comms_cap_change_template_id,
      to: recipient,
      personalisation: personalisation,
    )
  end

private

  def setup_params
    @school = params[:school]
    @new_cap_value = params[:new_cap_value]
  end

  def personalisation
    {
      school_name: @school.name,
      urn: @school.urn,
      new_cap_value: @new_cap_value,
    }
  end

  def recipient
    Settings.computacenter.notify_email_address
  end

  def devices_cap_change_template_id
    Settings.govuk_notify.templates.computacenter.device_cap_change
  end

  def comms_cap_change_template_id
    Settings.govuk_notify.templates.computacenter.comms_cap_change
  end
end
