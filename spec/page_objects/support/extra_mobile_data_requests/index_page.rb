module PageObjects
  module Support
    module ExtraMobileDataRequests
      class IndexPage < PageObjects::BasePage
        set_url '/support/extra-mobile-data-requests'

        elements :search_form, 'form#extra_mobile_data_requests_search_form'
        element :requests_table, '.requests'

        def row_for(request)
          requests_table.find("tr#request-#{request.id}")
        end
      end
    end
  end
end
