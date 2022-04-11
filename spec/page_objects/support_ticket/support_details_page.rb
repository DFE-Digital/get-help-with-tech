module PageObjects
  module SupportTicket
    class SupportDetailsPage < PageObjects::BasePage
      set_url '/get-support/support-details'

      element :heading, '.govuk-fieldset__legend--xl'
      element :message_field, '#support-ticket-support-details-form-message-field'
      element :continue_button, :button, text: 'Continue'

      def enter_dummy_support_details_and_continue
        message_field.set 'Dummy message'
        continue_button.click
      end
    end
  end
end
