class RestrictedDevicePasswordsMailer < ApplicationMailer
  def notify_restricted_devices
    @organisation_name = params[:organisation_name]
    @link_to_file = params[:link_to_file]
    @user = params[:user]

    tracked_template_mail(:notify_restricted_devices,
                          notify_restricted_devices_template_id,
                          to: user.email_address,
                          personalisation:)
  end

private

  attr_reader :link_to_file, :organisation_name, :user

  def tracked_template_mail(message_type, template_id, **mail_params)
    audit = EmailAudit.create!(message_type:,
                               template: template_id,
                               email_address: user.email_address,
                               user:)

    template_mail(template_id, mail_params.merge(reference: audit.id))
  end

  def notify_restricted_devices_template_id
    Settings.govuk_notify.templates.devices.notify_restricted_devices
  end

  def personalisation
    { organisation_name:, link_to_file: }
  end
end
