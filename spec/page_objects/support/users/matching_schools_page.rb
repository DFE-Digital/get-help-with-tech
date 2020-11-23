module PageObjects
  module Support
    module Users
      class MatchingSchoolsPage < PageObjects::BasePage
        set_url '/support/users/{id}/schools'

        element :associate_school_link, 'table.schools tbody tr input[type=submit][value=Associate]'
        elements :schools, 'table.schools tbody tr'
        elements :school_names, 'table.schools tbody tr td:first-child a'
      end
    end
  end
end
