module PageObjects
  module SupportTicket
    class SupportNeedsPage < PageObjects::BasePage
      set_url '/get-support/support-needs'

      element :heading, '.govuk-fieldset__legend--xl'
      element :laptops_checkbox_option, '#new_support_ticket_support_needs_form #laptops_and_tablets_option'
      # element :laptops_suggestions, '#support-ticket-support-needs-form-support-topics-laptops-and-tablets-conditional'
      element :routers_checkbox_option, '#new_support_ticket_support_needs_form #4g_wireless_routers_and_internet_access_option'
      # element :routers_suggestions, '#support-ticket-support-needs-form-support-topics-4g-wireless-routers-and-internet-access-conditional'
      element :platforms_checkbox_option, '#new_support_ticket_support_needs_form #digital_education_platforms_option'
      element :training_and_support_checkbox_option, '#new_support_ticket_support_needs_form #technology_training_and_support_option'
      element :something_else_checkbox_option, '#new_support_ticket_support_needs_form #something_else_option'
      element :continue_button, :button, text: 'Continue'

      def select_anything_and_continue
        laptops_checkbox_option.click
        continue_button.click
      end
    end
  end
end
