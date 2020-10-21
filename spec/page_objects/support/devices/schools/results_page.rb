module PageObjects
  module Support
    module Devices
      module School
        class ResultsPage < PageObjects::BasePage
          set_url '/support/devices/schools/results'

          element :another_search, 'a', text: 'Perform another search'
          section :results_table, 'table.schools' do
            elements :schools, 'tbody tr'
          end
        end
      end
    end
  end
end
