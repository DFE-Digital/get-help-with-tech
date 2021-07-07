module PageObjects
  module Support
    class AddressPage < PageObjects::BasePage
      set_url '/support/schools/{urn}/address/edit'

      element :h1, 'h1'

      element :address_1_field, '#school-address-1-field'
      element :address_2_field, '#school-address-2-field'
      element :address_3_field, '#school-address-3-field'

      element :town_field, '#school-town-field'
      element :county_field, '#school-county-field'
      element :postcode_field, '#school-postcode-field'

      element :submit, 'button[type=submit]'
    end
  end
end
