module PageObjects
  module Support
    module Devices
      class EnableOrdersPage < PageObjects::BasePage
        set_url '/support/devices/schools{/urn}/enable-orders'

        element :no, '#support-enable-orders-form-order-state-cannot-order-field'
        element :no_school_reopened, '#asd'
        element :yes_specific_cirumstances, '#support-enable-orders-form-order-state-can-order-for-specific-circumstances-field'
        element :how_many_devices, '#support-enable-orders-form-cap-field'
        element :yes, '#support-enable-orders-form-order-state-can-order-field'

        element :continue, 'input[value=Continue]'
      end
    end
  end
end
