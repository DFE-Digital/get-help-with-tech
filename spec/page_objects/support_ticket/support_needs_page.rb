module PageObjects
  module SupportTicket
    class SupportNeedsPage < PageObjects::BasePage
      set_url '/get-support/support-needs'

      element :heading, '.govuk-fieldset__legend--xl'
      element :laptops_checkbox_option, '#support-ticket-support-needs-form-support-topics-laptops-and-tablets-field'
      # element :laptops_suggestions, '#support-ticket-support-needs-form-support-topics-laptops-and-tablets-conditional'
      element :routers_checkbox_option, '#support-ticket-support-needs-form-support-topics-4g-wireless-routers-and-internet-access-field'
      # element :routers_suggestions, '#support-ticket-support-needs-form-support-topics-4g-wireless-routers-and-internet-access-conditional'
      element :platforms_checkbox_option, '#support-ticket-support-needs-form-support-topics-digital-education-platforms-field'
      element :training_and_support_checkbox_option, '#support-ticket-support-needs-form-support-topics-technology-training-and-support-field'
      element :something_else_checkbox_option, '#support-ticket-support-needs-form-support-topics-something-else-field'
      element :continue_button, :button, text: 'Continue'

      def select_anything_and_continue
        laptops_checkbox_option.click
        continue_button.click
      end
    end
  end
end
