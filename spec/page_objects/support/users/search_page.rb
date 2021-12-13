module PageObjects
  module Support
    module Users
      class SearchPage < PageObjects::BasePage
        set_url '/support/users/search'

        element :search_term, 'input[type=text]'
        element :submit, 'button[type=submit]'
        element :audit_data_checkbox, 'input[name="include_audit_data"]'
        element :export_button, 'button[name="export"]'
      end
    end
  end
end
