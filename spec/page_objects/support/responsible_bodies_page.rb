module PageObjects
  module Support
    class ResponsibleBodiesPage < PageObjects::BasePage
      set_url '/support/responsible-bodies'

      elements :responsible_body_rows, '#responsible-bodies tbody tr'
    end
  end
end
