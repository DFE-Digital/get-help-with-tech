class ExtraMobileDataRequestPresenter < SimpleDelegator
  def network_name
    mobile_network.brand if mobile_network.present?
  end

  def error_message
    return unless errors.any?

    msgs = []
    errors.messages.each_key do |k|
      case k
      when :device_phone_number
        msgs << if device_phone_number.present?
                  'Not a mobile number'
                else
                  'No mobile number provided'
                end
      when :mobile_network_id
        msgs << 'Not a known network'
      when :account_holder_name
        msgs << 'No account holder provided'
      when :agrees_with_privacy_statement
        msgs << 'Privacy statement not shared with account holder'
      end
    end
    msgs.join('<br/>').html_safe
  end

private

  def extra_mobile_data_request
    __getobj__
  end
end
