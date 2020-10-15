class Support::EmailAuditListComponent < ViewComponent::Base
  attr_reader :email_audits

  def initialize(email_audits)
    @email_audits = email_audits
  end

  def govuk_notify_template_deeplink_url(template_id)
    "https://www.notifications.service.gov.uk/services/#{Settings.govuk_notify.service_id}/templates/#{template_id}"
  end
end
