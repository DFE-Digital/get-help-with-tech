module PageObjects
  module Support
    module Users
      class InviteNewUserPage < PageObjects::BasePage
        set_url_matcher %r{/support/(schools|responsible-bodies)/\d+/users/new}

        element :name, 'input[name="user[full_name]"]'
        element :email_address, 'input[name="user[email_address]"]'
        element :phone, 'input[name="user[telephone]"]'
        element :send_invite, 'button[type=submit]'
      end
    end
  end
end
