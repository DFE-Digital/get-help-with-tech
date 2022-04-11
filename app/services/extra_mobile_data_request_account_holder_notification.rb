class ExtraMobileDataRequestAccountHolderNotification
  attr_reader :extra_mobile_data_request

  def initialize(extra_mobile_data_request)
    @extra_mobile_data_request = extra_mobile_data_request
  end

  def deliver_now
    build_message.deliver!
  end

  def deliver_later
    NotifyExtraMobileDataRequestAccountHolderJob.perform_later(extra_mobile_data_request)
  end

private

  def build_message
    @message ||= NotifySmsMessage.new(
      phone_number:,
      template_id:,
      personalisation:,
    )
  end

  def phone_number
    extra_mobile_data_request.device_phone_number
  end

  def personalisation
    {
      mno: extra_mobile_data_request.mobile_network.brand,
    }
  end

  def template_id
    templates = Settings.govuk_notify.templates.extra_mobile_data_requests

    if extra_mobile_data_request.mobile_network.participating?
      templates.mno_in_scheme_sms
    else
      templates.mno_not_in_scheme_sms
    end
  end
end
