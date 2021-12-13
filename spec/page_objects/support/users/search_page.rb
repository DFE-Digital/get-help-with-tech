module PageObjects
  module Support
    module Users
      class SearchPage < PageObjects::BasePage
        set_url '/support/users/search'

        element :search_term, 'input[type=text]'
        element :submit, 'button[type=submit]'
        element :export_button, 'input[name="export"]'
      end
    end
  end
end
