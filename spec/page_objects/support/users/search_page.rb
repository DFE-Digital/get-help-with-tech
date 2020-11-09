module PageObjects
  module Support
    module Users
      class SearchPage < PageObjects::BasePage
        set_url '/support/users/search'

        element :search_term, 'input[type=text]'
        element :submit, 'input[value=Search]'
      end
    end
  end
end
