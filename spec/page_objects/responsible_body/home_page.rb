module PageObjects
  module ResponsibleBody
    class HomePage < PageObjects::BasePage
      set_url '/responsible_body'

      elements :allocation_request_rows, '.govuk-summary-list__row'

      def elligible_young_people
        matching_row = allocation_request_rows.select { |row|
          row.has_text? I18n.t('responsible_body.home.show.number_eligible')
        }.first
        matching_row.find('.govuk-summary-list__value')
      end

      def number_who_can_see_a_bt_hotspot
        matching_row = allocation_request_rows.select { |row|
          row.has_text? I18n.t('responsible_body.home.show.number_eligible_with_hotspot_access')
        }.first
        matching_row.find('.govuk-summary-list__value')
      end
    end
  end
end
