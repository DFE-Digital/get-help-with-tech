module PageObjects
  module SupportTicket
    class DescribeYourselfPage < PageObjects::BasePage
      set_url '/get-support/describe-yourself'

      element :heading, '.govuk-fieldset__legend--xl'
      element :school_radio_button, '#support-ticket-describe-yourself-form-user-type-school-or-single-academy-trust-field'
      element :school_suggestions, '#support-ticket-describe-yourself-form-user-type-multi-academy-trust-conditional'
      element :mat_radio_button, '#support-ticket-describe-yourself-form-user-type-multi-academy-trust-field'
      element :mat_suggestions, '#support-ticket-describe-yourself-form-user-type-multi-academy-trust-conditional'
      element :la_radio_button, '#support-ticket-describe-yourself-form-user-type-local-authority-field'
      element :la_suggestions, '#support-ticket-describe-yourself-form-user-type-local-authority-conditional'
      element :college_radio_button, '#support-ticket-describe-yourself-form-user-type-college-field'
      element :college_suggestions, '#support-ticket-describe-yourself-form-user-type-college-conditional'
      element :individual_radio_button, '#support-ticket-describe-yourself-form-user-type-parent-or-guardian-or-carer-or-pupil-or-care-leaver-field'
      element :individual_suggestions, '#support-ticket-describe-yourself-form-user-type-parent-or-guardian-or-carer-or-pupil-or-care-leaver-conditional'
      element :none_above_radio_button, '#support-ticket-describe-yourself-form-user-type-other-type-of-user-field'
      element :none_above_suggestions, '#support-ticket-describe-yourself-form-user-type-other-type-of-user-conditional'
      element :continue_button, :button, text: 'Continue'

      def load_then_select_anything_and_continue
        load_select_option_and_continue
      end

      def load_select_option_and_continue(describe_option: :school)
        load
        send("#{describe_option}_radio_button").click
        continue_button.click
      end
    end
  end
end
