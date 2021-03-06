class ExtraMobileDataRequestPresenter < SimpleDelegator
  def network_name
    mobile_network.brand if mobile_network.present?
  end

  def network_name_with_participation_status
    name = network_name
    return name if mobile_network.participating?

    I18n.t(:mobile_network_not_on_service_yet, scope: i18n_scope, mno: name)
  end

  def passing_data_to_provider_message
    if mobile_network.participating?
      I18n.t(:details_passed_to_provider, scope: i18n_scope, mno: network_name)
    else
      I18n.t(:details_passed_to_provider_only_if_they_join, scope: i18n_scope, mno: network_name)
    end
  end

  def error_message
    errors.messages.values.join('<br>').html_safe
  end

  def contract_type_options
    i18n_scope = 'responsible_body.extra_mobile_data_requests.new'
    ExtraMobileDataRequest.contract_types.values.reverse.map do |ct|
      OpenStruct.new(value: ct, label: I18n.t(ct, scope: i18n_scope))
    end
  end

private

  def extra_mobile_data_request
    __getobj__
  end

  def i18n_scope
    'responsible_body.extra_mobile_data_requests'
  end
end
