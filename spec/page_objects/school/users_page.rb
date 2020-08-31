module PageObjects
  module School
    class UsersPage < PageObjects::BasePage
      set_url '/school/users'

      elements :user_rows, '#user-list .user'
    end
  end
end
