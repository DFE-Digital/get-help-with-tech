module PageObjects
  module SupportTicket
    class DescribeYourselfPage < PageObjects::BasePage
      set_url '/get-support/describe-yourself'

      element :school_radio_button, '#support-ticket-describe-yourself-form-user-type-school-or-single-academy-trust-field'
      element :mat_radio_button, '#support-ticket-describe-yourself-form-user-type-multi-academy-trust-field'
      element :la_radio_button, '#support-ticket-describe-yourself-form-user-type-local-authority-field'
      element :college_radio_button, '#support-ticket-describe-yourself-form-user-type-college-field'
      element :individual_radio_button, '#support-ticket-describe-yourself-form-user-type-parent-or-guardian-or-carer-or-pupil-or-care-leaver-field'
      element :none_above_radio_button, '#support-ticket-describe-yourself-form-user-type-other-type-of-user-field'
      element :continue_button, :button, text: 'Continue'
    end
  end
end
