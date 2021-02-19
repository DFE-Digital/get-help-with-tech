module PageObjects
  module Support
    module ExtraMobileDataRequests
      class IndexPage < PageObjects::BasePage
        set_url '/support/extra-mobile-data-requests'

        elements :search_form, 'form#extra_mobile_data_requests_search_form'
        element :requests_table, '.requests'
        elements :request_rows, 'table.requests tbody tr'
        elements :request_brands, 'table.requests tbody td.brand'
        element :request_id_field, '#emdr-search-request-id-field'
        element :mobile_network_field, '#emdr-search-mno-id-field'
        element :responsible_body_field, '#emdr-search-rb-id-field'
        element :urn_or_ukprn_field, '#emdr-search-urn-or-ukprn-field'

        def row_for(request)
          requests_table.find("tr#request-#{request.id}")
        end

        def search_for_requests
          find('span', text: 'Search for requests')
        end
      end
    end
  end
end
