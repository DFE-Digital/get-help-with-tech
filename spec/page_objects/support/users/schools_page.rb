module PageObjects
  module Support
    module Users
      class SchoolsPage < PageObjects::BasePage
        set_url '/support/users/{id}/schools'

        element :school_name_or_urn, 'input#support-school-suggestion-form-name-or-urn-field'
        element :school_urn, 'input#support_school_suggestion_form_school_urn'
        element :submit_school_name_or_urn, '#new_support_school_suggestion_form input[value=Continue]'
      end
    end
  end
end
