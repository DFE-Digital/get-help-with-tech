module PageObjects
  module Support
    module Users
      class SchoolsPage < PageObjects::BasePage
        set_url '/support/users/{id}/schools'

        element :school_name_or_urn, 'input#support-new-user-school-form-name-or-urn-field'
        element :school_urn, 'input#support_new_user_school_form_school_urn'
        element :submit_school_name_or_urn, '#new_support_new_user_school_form input[value=Continue]'
        elements :schools, 'table.schools tbody tr'
      end
    end
  end
end
