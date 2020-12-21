module PageObjects
  module Support
    module Users
      class MatchingSchoolsPage < PageObjects::BasePage
        set_url '/support/users/{id}/schools/new'

        element :form_with_suggested_schools, '#new_support_new_user_school_form'
        element :existing_schools, '#existing-schools'
      end
    end
  end
end
