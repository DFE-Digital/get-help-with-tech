module PageObjects
  module Support
    module School
      class SearchPage < PageObjects::BasePage
        set_url '/support/schools/search'

        element :search_by_name_urn_or_ukprn, '#school-search-form-search-type-single-field'
        element :search_by_multiple_urn_or_ukprns, '#school-search-form-search-type-multiple-field'
        element :search_by_rb_or_order_state, '#school-search-form-search-type-responsible-body-or-order-state-field'

        element :name_or_identifier, 'input#school-search-form-name-or-identifier-field'
        element :identifiers, 'textarea#school-search-form-identifiers-field'
        element :responsible_body, 'select#school-search-form-responsible-body-id-field'
        element :order_state, 'select#school-search-form-order-state-field'
        element :submit, 'button[type=submit]'
      end
    end
  end
end
