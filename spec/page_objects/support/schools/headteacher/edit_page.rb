module PageObjects
  module Support
    module School
      module Headteacher
        class EditPage < PageObjects::BasePage
          set_url_matcher /\/support\/schools\/\d+\/headteacher(\/edit)?/

          element :error_summary, '.govuk-error-summary'

          element :school_name_header, 'h1.govuk-heading-xl span.govuk-caption-xl'

          element :title_label, 'form label[for=support-school-change-headteacher-form-title-field]'
          element :title_field, 'input#support-school-change-headteacher-form-title-field'

          element :full_name_label, 'form label[for=support-school-change-headteacher-form-full-name-field]'
          element :full_name_field, 'input#support-school-change-headteacher-form-full-name-field'

          element :email_address_label, 'form label[for=support-school-change-headteacher-form-email-address-field]'
          element :email_address_error_message, '#support-school-change-headteacher-form-email-address-error'
          element :email_address_field, 'input#support-school-change-headteacher-form-email-address-field[type=email]'
          element :email_address_error_field, 'input#support-school-change-headteacher-form-email-address-field-error[type=email]'

          element :phone_number_label, 'form label[for=support-school-change-headteacher-form-phone-number-field]'
          element :phone_number_field, 'input#support-school-change-headteacher-form-phone-number-field'

          element :submit_button, 'form button.govuk-button[type=submit]'
        end
      end
    end
  end
end
