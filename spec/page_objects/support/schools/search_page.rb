module PageObjects
  module Support
    module School
      class SearchPage < PageObjects::BasePage
        set_url '/support/schools/search'

        element :identifiers, 'textarea#school-search-form-identifiers-field'
        element :responsible_body, 'select#school-search-form-responsible-body-id-field'
        element :order_state, 'select#school-search-form-order-state-field'
        element :submit, 'input[value=Search]'
      end
    end
  end
end
