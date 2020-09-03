module PageObjects
  module Support
    module Devices
      class ResponsibleBodyPage < PageObjects::BasePage
        set_url '/support/devices/responsible-bodies{/id}'

        elements :user_rows, '#responsible-body-users tbody tr'
        elements :school_rows, '#responsible-body-schools tbody tr'
      end
    end
    module Internet
      class ResponsibleBodyPage < PageObjects::BasePage
        set_url '/support/internet/responsible-bodies{/id}'

        elements :user_rows, '#responsible-body-users tbody tr'
      end
    end
  end
end
