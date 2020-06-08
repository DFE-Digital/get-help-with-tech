def create_participating_mobile_network
  MobileNetwork.create!(
    brand: 'Participating mobile network',
    host_network: 'AA',
    participating_in_scheme: true
  )
end

def destroy_participating_mobile_network
  MobileNetwork.where(brand: 'Participating mobile network').destroy_all
end

def fill_in_valid_application_form
  fill_in 'Your full name', with: 'Bob Boberts'
  fill_in 'Your email address', with: 'validmail@localauthority.gov.uk'
  fill_in 'Name of the organisation you work for', with: 'A Local Authority'

  fill_in 'Name of the eligible child or young person', with: 'young person'
  fill_in 'Address of the child or young person', with: '1 some street\nsome town'
  fill_in 'Postcode of the child or young person', with: 'AB128TH'

  find('#application-form-can-access-hotspot-yes-field').choose
  find('#application-form-is-account-holder-yes-field').choose
  fill_in 'Phone number of device', with: '0123456789'

  select 'Participating mobile network', from: 'Name of phone network'
  find('#application-form-privacy-statement-sent-to-family-yes-field').choose
  find('#application-form-understands-how-pii-will-be-used-yes-field').choose
end
