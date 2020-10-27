module PageObjects
  module Support
    module School
      class SearchPage < PageObjects::BasePage
        set_url '/support/schools/search'

        element :urns, 'textarea#bulk-urn-search-form-urns-field'
        element :submit, 'input[value=Search]'
      end
    end
  end
end
