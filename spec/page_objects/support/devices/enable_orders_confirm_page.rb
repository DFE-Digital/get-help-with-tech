module PageObjects
  module Support
    module Devices
      class EnableOrdersConfirmPage < PageObjects::BasePage
        set_url '/support/devices/schools{/urn}/enable-orders/confirm'

        elements :school_details_rows, '.govuk-summary-list .govuk-summary-list__row'

        def can_order_devices_row
          school_details_rows[0]
        end

        def how_many_devices_row
          school_details_rows[1]
        end
      end
    end
  end
end
