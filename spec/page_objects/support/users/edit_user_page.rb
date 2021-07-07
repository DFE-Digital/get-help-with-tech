module PageObjects
  module Support
    module Users
      class EditUserPage < PageObjects::BasePage
        element :name, 'input[name="user[full_name]"]'
        element :email_address, 'input[name="user[email_address]"]'
        element :save_changes, 'button[type=submit]'
      end
    end
  end
end
