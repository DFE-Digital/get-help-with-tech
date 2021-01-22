module PageObjects
  module School
    module Internet
      class YourRequestsPage < PageObjects::BasePage
        set_url '/schools{/urn}/internet/mobile/requests'

        element :heading, 'h1'
        element :requests_table, '.requests'

        def row_for(request)
          requests_table.find("tr#request-#{request.id}")
        end
      end
    end
  end
end
