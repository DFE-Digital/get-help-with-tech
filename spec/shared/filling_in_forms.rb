def fill_in_valid_application_form(mobile_network_name: 'Participating mobile network')
  fill_in 'Account holder name', with: 'Anne Account-Holder'
  fill_in 'Mobile phone number', with: '07123456789'

  choose mobile_network_name
  check('Yes, they agree with the privacy statement')
end
