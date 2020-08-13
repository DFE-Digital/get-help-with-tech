module PageObjects
  module Support
    class ResponsibleBodyPage < PageObjects::BasePage
      set_url '/support/responsible-bodies{/id}'

      elements :user_rows, '#responsible-body-users tbody tr'
    end
  end
end
