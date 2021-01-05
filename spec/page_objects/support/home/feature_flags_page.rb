module PageObjects
  module Support
    module Home
      class FeatureFlagsPage < PageObjects::BasePage
        class Row < SitePrism::Section
          element :key_cell, 'th'
          element :status_cell, 'td'

          def key
            key_cell.text
          end

          def status
            status_cell.text
          end
        end

        class Table < SitePrism::Section
          sections :rows, Row, 'tbody tr'

          def [](key)
            rows.find { |row| row.key == key }
          end
        end

        set_url '/support/feature-flags'

        section :table, Table, 'table'
      end
    end
  end
end
