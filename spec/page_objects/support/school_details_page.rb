module PageObjects
  module Support
    class SchoolDetailsPage < PageObjects::BasePage
      set_url '/support/schools/{urn}'

      elements :school_details_rows, '.school-details-summary-list .govuk-summary-list__row'

      element :contacts, 'table#contacts'
      element :invite_a_new_user, 'a', text: 'Invite a new user'
    end
  end
end
