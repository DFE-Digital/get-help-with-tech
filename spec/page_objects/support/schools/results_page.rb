module PageObjects
  module Support
    module School
      class ResultsPage < PageObjects::BasePage
        set_url '/support/schools/results'

        element :another_search, 'a', text: 'Try another search'
        section :results_table, 'table.schools' do
          elements :schools, 'tbody tr'
          elements :responsible_bodies, 'tbody tr td[3]'
          elements :order_states, 'tbody tr td[5]'
        end
      end
    end
  end
end
