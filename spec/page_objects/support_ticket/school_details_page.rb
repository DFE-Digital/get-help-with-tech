module PageObjects
  module SupportTicket
    class SchoolDetailsPage < PageObjects::BasePage
      set_url '/get-support/school-details'

      element :heading, '.govuk-heading-xl'
      element :school_name_field, '#support-ticket-school-details-form-school-name-field'
      element :school_urn_field, '#support-ticket-school-details-form-school-urn-field'
      element :continue_button, :button, text: 'Continue'

      def enter_dummy_school_details_and_continue
        school_name_field.set 'Dummy School'
        school_urn_field.set '12345678'
        continue_button.click
      end
    end
  end
end
