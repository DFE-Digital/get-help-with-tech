module PageObjects
  module Support
    module Users
      class AssociatedOrganisationsPage < PageObjects::BasePage
        set_url '/support/users/{id}/associated-organisations'

        element :school_name_or_urn, 'input#support-new-user-school-form-name-or-urn-field'
        element :submit_school_name_or_urn, '#new_support_new_user_school_form input[value=Continue]'
        elements :schools, 'table.schools tbody tr'

        element :responsible_body_name, 'input#support-user-responsible-body-form-name-field'
        element :submit_responsible_body_name, '#new_support_user_responsible_body_form input[value=Continue]'
        element :responsible_body, 'table.responsible-body tbody tr'

        def has_responsible_body?
          has_selector?(responsible_body)
        end
      end
    end
  end
end
