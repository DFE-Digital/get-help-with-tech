module PageObjects
  module ResponsibleBody
    class HomePage < PageObjects::BasePage
      set_url '/responsible-body'

      elements :allocation_request_rows, '.govuk-summary-list__row'
      element :step_1_status, '#step-1-status'

      def eligible_young_people
        matching_row = allocation_request_rows.select { |row|
          row.has_text? I18n.t('responsible_body.home.bt_wifi_offer.number_eligible')
        }.first
        matching_row.find('.govuk-summary-list__value')
      end

      def number_who_can_see_a_bt_hotspot
        matching_row = allocation_request_rows.select { |row|
          row.has_text? I18n.t('responsible_body.home.bt_wifi_offer.number_eligible_with_hotspot_access')
        }.first
        matching_row.find('.govuk-summary-list__value')
      end
    end
  end
end
