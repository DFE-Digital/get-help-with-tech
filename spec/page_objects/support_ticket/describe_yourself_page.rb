module PageObjects
  module SupportTicket
    class DescribeYourselfPage < PageObjects::BasePage
      set_url '/get-support/describe-yourself'

      element :heading, '.govuk-fieldset__legend--xl'
      element :school_radio_button, '#new_support_ticket_describe_yourself_form #school_or_single_academy_trust_option'
      element :school_suggestions, '#support-ticket-describe-yourself-form-user-type-multi-academy-trust-conditional'
      element :mat_radio_button, '#new_support_ticket_describe_yourself_form #multi_academy_trust_option'
      element :mat_suggestions, '#support-ticket-describe-yourself-form-user-type-multi-academy-trust-conditional'
      element :la_radio_button, '#new_support_ticket_describe_yourself_form #local_authority_option'
      element :la_suggestions, '#support-ticket-describe-yourself-form-user-type-local-authority-conditional'
      element :college_radio_button, '#new_support_ticket_describe_yourself_form #college_option'
      element :college_suggestions, '#support-ticket-describe-yourself-form-user-type-college-conditional'
      element :individual_radio_button, '#new_support_ticket_describe_yourself_form #parent_or_guardian_or_carer_or_pupil_or_care_leaver_option'
      element :individual_suggestions, '#support-ticket-describe-yourself-form-user-type-parent-or-guardian-or-carer-or-pupil-or-care-leaver-conditional'
      element :none_above_radio_button, '#new_support_ticket_describe_yourself_form #other_type_of_user_option'
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
