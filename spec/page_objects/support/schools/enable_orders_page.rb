module PageObjects
  module Support
    module Schools
      module Devices
        class EnableOrdersPage < PageObjects::BasePage
          set_url '/support/devices/schools{/urn}/enable-orders'

          element :no, '#support-enable-orders-form-order-state-cannot-order-field'
          element :no_school_reopened, '#support-enable-orders-form-order-state-cannot-order-as-reopened-field'
          element :yes_specific_cirumstances, '#support-enable-orders-form-order-state-can-order-for-specific-circumstances-field'
          element :how_many_devices, '#support-enable-orders-form-device-cap-field'
          element :how_many_routers, '#support-enable-orders-form-router-cap-field'
          element :yes, '#support-enable-orders-form-order-state-can-order-field'

          element :continue, 'button[type=submit]'
        end
      end
    end
  end
end
