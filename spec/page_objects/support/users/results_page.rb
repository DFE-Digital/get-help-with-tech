module PageObjects
  module Support
    module Users
      class ResultsPage < PageObjects::BasePage
        set_url '/support/users/results'

        element :another_search, 'a', text: 'Search again'
        elements :users, 'ul.search-results > li'
      end
    end
  end
end
