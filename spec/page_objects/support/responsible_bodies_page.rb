module PageObjects
  module Support
    module Internet
      class ResponsibleBodiesPage < PageObjects::BasePage
        set_url '/support/internet/responsible-bodies'

        elements :responsible_body_rows, '#responsible-bodies tbody tr'
      end
    end
    module Devices
      class ResponsibleBodiesPage < PageObjects::BasePage
        set_url '/support/devices/responsible-bodies'

        elements :responsible_body_rows, '#responsible-bodies tbody tr'
      end
    end
  end
end
