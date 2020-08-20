module PageObjects
  module ResponsibleBody
    class UsersPage < PageObjects::BasePage
      set_url '/responsible-body/users'

      elements :user_rows, '#user-list .user'
    end
  end
end
