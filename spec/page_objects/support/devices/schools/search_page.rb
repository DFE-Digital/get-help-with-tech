module PageObjects
  module Support
    module Devices
      module School
        class SearchPage < PageObjects::BasePage
          set_url '/support/devices/schools/search'

          element :urns, 'textarea#bulk-urn-search-form-urns-field'
          element :submit, 'input[value=Search]'
        end
      end
    end
  end
end
