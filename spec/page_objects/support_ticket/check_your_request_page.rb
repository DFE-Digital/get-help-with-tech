module PageObjects
  module SupportTicket
    class CheckYourRequestPage < PageObjects::BasePage
      set_url '/get-support/check-your-request'

      element :heading, '.govuk-heading-xl'
      element :which_of_these_best_describes_you, '.which_of_these_best_describes_you'
      element :which_school_are_you_in, '.which_school_are_you_in'
      element :how_can_we_contact_you, '.how_can_we_contact_you'
      element :what_do_you_need_help_with, '.what_do_you_need_help_with'
      element :how_can_we_help_you, '.how_can_we_help_you'
      element :continue_button, :button, text: 'Submit request'
    end
  end
end
