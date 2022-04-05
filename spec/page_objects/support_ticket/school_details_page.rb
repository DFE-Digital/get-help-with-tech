module PageObjects
  module SupportTicket
    class SchoolDetailsPage < PageObjects::BasePage
      set_url '/get-support/school-details'

      element :school_name_field, '#support-ticket-school-details-form-school-name-field'
      element :school_urn_field, '#support-ticket-school-details-form-school-urn-field'
      element :continue_button, :button, text: 'Continue'
    end
  end
end
