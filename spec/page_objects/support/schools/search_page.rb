module PageObjects
  module Support
    module School
      class SearchPage < PageObjects::BasePage
        set_url '/support/schools/search'

        element :urns, 'textarea#bulk-school-search-form-identifiers-field'
        element :submit, 'input[value=Search]'
      end
    end
  end
end
