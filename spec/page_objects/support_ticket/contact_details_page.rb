module PageObjects
  module SupportTicket
    class ContactDetailsPage < PageObjects::BasePage
      set_url '/get-support/contact-details'

      element :your_full_name_field, '#support-ticket-contact-details-form-full-name-field'
      element :your_email_address_field, '#support-ticket-contact-details-form-email-address-field'
      element :telephone_number_field, '#support-ticket-contact-details-form-telephone-number-field'
      element :continue_button, :button, text: 'Continue'
    end
  end
end
