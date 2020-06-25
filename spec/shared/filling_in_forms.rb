def fill_in_valid_application_form(mobile_network_name: 'Participating mobile network')
  find('#application-form-can-access-hotspot-yes-field').choose

  fill_in 'Account holder name', with: 'Anne Account-Holder'
  fill_in 'Mobile phone number', with: '07123456789'

  select mobile_network_name, from: 'Mobile network'
  find('#application-form-privacy-statement-sent-to-family-yes-field').choose
  find('#application-form-understands-how-pii-will-be-used-yes-field').choose
end
