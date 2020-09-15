module PageObjects
  module Support
    module Devices
      class SchoolDetailsPage < PageObjects::BasePage
        elements :school_details_rows, '.school-details-summary-list .govuk-summary-list__row'
      end
    end
  end
end
