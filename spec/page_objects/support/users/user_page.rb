module PageObjects
  module Support
    module Users
      class UserPage < PageObjects::BasePage
        set_url '/support/users{/user_id}'

        element :summary_list, 'dl'
      end
    end
  end
end
