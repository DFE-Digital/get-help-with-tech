module PageObjects
  module SupportTicket
    class GetSupportPage < PageObjects::BasePage
      set_url '/get-support'

      element :start_now_button, 'a', text: 'Start now'
    end
  end
end
