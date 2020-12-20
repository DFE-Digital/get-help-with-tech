module PageObjects
  module Support
    module Users
      class SchoolsPage < PageObjects::BasePage
        set_url '/support/users/{id}/schools'

        element :school_name_or_urn, 'input#support-new-user-school-form-name-or-urn-field'
        element :submit_school_name_or_urn, '#new_support_new_user_school_form input[value=Continue]'
      end
    end
  end
end
