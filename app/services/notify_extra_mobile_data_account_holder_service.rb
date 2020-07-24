class NotifyExtraMobileDataAccountHolderService
  class NotifySmsError < StandardError; end

  def self.call(extra_mobile_data_request)
    new(extra_mobile_data_request).call
  end

  def initialize(extra_mobile_data_request)
    @extra_mobile_data_request = extra_mobile_data_request
  end

  def call
    @response = sms_client.send_sms(
      phone_number: telephone,
      template_id: template_id,
      personalisation: {
        mno: mno_name,
      },
    )
  rescue Notifications::Client::RequestError => e
    Rails.logger.error(e.message)
    raise NotifySmsError, e
  end

private

  def sms_client
    @sms_client ||= Notifications::Client.new(api_key)
  end

  def api_key
    Settings.govuk_notify.api_key
  end

  def telephone
    @extra_mobile_data_request.device_phone_number
  end

  def mno_name
    @extra_mobile_data_request.mobile_network.brand
  end

  def mno_participating_in_scheme?
    @extra_mobile_data_request.mobile_network.participating?
  end

  def template_id
    templates = Settings.govuk_notify.templates.extra_mobile_data_requests

    if mno_participating_in_scheme?
      templates.mno_in_scheme_sms
    else
      templates.mno_not_in_scheme_sms
    end
  end
end
