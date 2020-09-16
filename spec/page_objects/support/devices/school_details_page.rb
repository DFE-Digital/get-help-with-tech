module PageObjects
  module Support
    module Devices
      class SchoolDetailsPage < PageObjects::BasePage
        set_url '/support/devices/schools/{urn}'

        elements :school_details_rows, '.school-details-summary-list .govuk-summary-list__row'

        element :contacts, 'table#contacts'
      end
    end
  end
end
