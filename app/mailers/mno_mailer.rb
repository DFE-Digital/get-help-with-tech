class MnoMailer < ApplicationMailer
  def notify_new_requests(user:, number_of_new_requests:)
    template_mail(
      notify_new_requests_template_id,
      to: user.email_address,
      personalisation: personalisation(user, number_of_new_requests),
    )

    audit_email(user:)
  end

private

  def audit_email(user:)
    EmailAudit.create!(message_type: 'notify_new_requests',
                       template: notify_new_requests_template_id,
                       email_address: user.email_address,
                       user:)
  end

  def personalisation(user, number_of_new_requests)
    {
      full_name: user.full_name,
      brand: user.mobile_network.brand,
      number: number_of_new_requests,
    }
  end

  def notify_new_requests_template_id
    Settings.govuk_notify.templates.mno.notify_new_requests
  end
end
