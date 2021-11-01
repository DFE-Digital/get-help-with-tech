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

  def notify_of_school_can_order
    setup_params

    template_mail(
      school_can_order_template_id,
      to: recipient,
      personalisation: personalisation,
    )
  end

private

  def setup_params
    logger.info "--- LOCAL DEBUG: #{self.class.name}.#{caller_locations(1, 1)[0].label}.with(#{params})" if ENV['LOCAL_DEBUG']
    @school = params[:school]
    @new_cap_value = params[:new_cap_value]
  end

  def personalisation
    {
      school_name: @school.name,
      urn: @school.urn,
      new_cap_value: @new_cap_value,
      ship_to_number: @school.computacenter_reference || 'Not set',
      responsible_body_name: @school.responsible_body.name,
      responsible_body_type: @school.responsible_body.humanized_type,
      responsible_body_reference: @school.responsible_body.computacenter_identifier,
      sold_to_number: @school.responsible_body.computacenter_reference || 'Not set',
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

  def school_can_order_template_id
    Settings.govuk_notify.templates.computacenter.school_can_order
  end
end
