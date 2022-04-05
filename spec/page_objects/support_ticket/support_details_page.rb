module PageObjects
  module SupportTicket
    class SupportDetailsPage < PageObjects::BasePage
      set_url '/get-support/support-details'

      element :message_field, '#support-ticket-support-details-form-message-field'
      element :continue_button, :button, text: 'Continue'
    end
  end
end
