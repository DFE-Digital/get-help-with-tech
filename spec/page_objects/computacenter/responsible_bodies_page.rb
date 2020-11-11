module PageObjects
  module Computacenter
    class ResponsibleBodiesPage < PageObjects::BasePage
      set_url '/computacenter/responsible-bodies'

      elements :responsible_body_rows, '#responsible-bodies tbody tr'
    end
  end
end
