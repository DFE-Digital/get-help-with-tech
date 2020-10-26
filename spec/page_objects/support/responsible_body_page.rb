module PageObjects
  module Support
    class ResponsibleBodyPage < PageObjects::BasePage
      set_url '/support/responsible-bodies{/id}'

      elements :users, '.user'
      elements :school_rows, '#responsible-body-schools tbody tr'
    end
  end
end
