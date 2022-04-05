module PageObjects
  module SupportTicket
    class CheckYourRequestPage < PageObjects::BasePage
      set_url '/get-support/check-your-request'

      element :continue_button, :button, text: 'Submit request'
    end
  end
end
