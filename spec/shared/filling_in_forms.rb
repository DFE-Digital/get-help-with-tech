def fill_in_valid_application_form(user_email: 'validmail@localauthority.gov.uk', mobile_network_name: 'Participating mobile network')
  fill_in 'Your full name', with: 'Bob Boberts'
  fill_in 'Your email address', with: user_email
  fill_in 'Name of the organisation you work for', with: 'A Local Authority'

  fill_in 'Name of the eligible child or young person', with: 'young person'
  fill_in 'Address of the child or young person', with: '1 some street\nsome town'
  fill_in 'Postcode of the child or young person', with: 'AB128TH'

  find('#application-form-can-access-hotspot-yes-field').choose
  find('#application-form-is-account-holder-yes-field').choose
  fill_in 'Phone number of device', with: '0123456789'

  select mobile_network_name, from: 'Name of phone network'
  find('#application-form-privacy-statement-sent-to-family-yes-field').choose
  find('#application-form-understands-how-pii-will-be-used-yes-field').choose
end
