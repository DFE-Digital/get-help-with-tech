module PageObjects
  module Support
    module Devices
      class EnableOrdersConfirmPage < PageObjects::BasePage
        set_url '/support/devices/schools{/urn}/enable-orders/confirm'

        elements :school_details_rows, '.school-details-summary-list .govuk-summary-list__row'
        elements :can_order_devices_row, '.school-details-summary-list .govuk-summary-list__row[0]'
        elements :how_many_devices_row, '.school-details-summary-list .govuk-summary-list__row[1]'
      end
    end
  end
end
