def fill_in_valid_application_form(mobile_network_name: 'Participating mobile network', contract_type: 'Pay as you go (PAYG)')
  fill_in 'Account holder name', with: 'Anne Account-Holder'
  fill_in 'Mobile phone number', with: '07123456780'

  choose mobile_network_name
  choose contract_type
  check('Yes, the privacy statement has been shared')
end
