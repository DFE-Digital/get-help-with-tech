module PageObjects
  module Computacenter
    module School
      class ResultsPage < PageObjects::BasePage
        set_url '/computacenter/schools/results'

        element :another_search, 'a', text: 'Try another search'
        section :results_table, 'table.schools' do
          elements :schools, 'tbody tr'
        end
      end
    end
  end
end
