module PageObjects
  module Support
    module Schools
      class BulkUploadAllocationPage < PageObjects::BasePage
        set_url '/support/schools/devices/enable-orders/for-many-schools'

        element :header, 'h1.govuk-heading-xl'
        element :choose_file_button, 'input#support-bulk-allocation-form-upload-field'

        element :send_notifications_yes_label, 'label[for=support-bulk-allocation-form-send-notification-true-field]'
        element :send_notifications, 'input[type=radio]#support-bulk-allocation-form-send-notification-true-field'

        element :send_notifications_no_label, 'label[for=support-bulk-allocation-form-send-notification-field]'
        element :do_not_send_notifications, 'input[type=radio]#support-bulk-allocation-form-send-notification-field'

        element :submit_button, 'form button.govuk-button[type=submit]'
      end
    end
  end
end
