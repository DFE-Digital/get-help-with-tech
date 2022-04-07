module PageObjects
  module SupportTicket
    class DescribeYourselfPage < PageObjects::BasePage
      set_url '/get-support/describe-yourself'

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
    end
  end
end
