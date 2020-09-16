module PageObjects
  module Support
    module Devices
      class ContactPage < PageObjects::BasePage
        element :full_name, 'input#school-contact-full-name-field'
        element :submit, 'input[value=Continue]'
      end
    end
  end
end
