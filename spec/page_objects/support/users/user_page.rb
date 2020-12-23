module PageObjects
  module Support
    module Users
      class UserPage < PageObjects::BasePage
        set_url '/support/users{/user_id}'

        section :summary_list, SummaryListSection, '.govuk-summary-list'
      end
    end
  end
end
