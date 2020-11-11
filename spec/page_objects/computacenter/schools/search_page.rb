module PageObjects
  module Computacenter
    module School
      class SearchPage < PageObjects::BasePage
        set_url '/computacenter/schools/search'

        element :urns, 'textarea#bulk-urn-search-form-urns-field'
        element :submit, 'input[value=Search]'
      end
    end
  end
end
