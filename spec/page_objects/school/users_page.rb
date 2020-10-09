module PageObjects
  module School
    class UsersPage < PageObjects::BasePage
      set_url '/schools{/urn}/users'

      elements :user_rows, '#user-list .user'
    end
  end
end
