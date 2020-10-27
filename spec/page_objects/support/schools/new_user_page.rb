module PageObjects
  module Support
    module Schools
      class NewUserPage < PageObjects::BasePage
        set_url '/support/schools/{urn}/users/new'

        element :name, '#user-full-name-field'
        element :email, '#user-email-address-field'
        element :phone, '#user-telephone-field'
        element :orders_devices_yes, '#user-orders-devices-1-field'
        element :orders_devices_no, '#user-orders-devices-0-field'
        element :submit, 'input[value="Send invite"]'
      end
    end
  end
end
