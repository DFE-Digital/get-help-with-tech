module PageObjects
  module Support
    module School
      class ResultsPage < PageObjects::BasePage
        set_url '/support/schools/results'

        element :another_search, 'a', text: 'Try another search'
        section :results_table, 'table.schools' do
          elements :schools, 'tbody tr'
        end
      end
    end
  end
end
