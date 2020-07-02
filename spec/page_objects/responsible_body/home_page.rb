module PageObjects
  module ResponsibleBody
    class HomePage < PageObjects::BasePage
      set_url '/responsible_body'

      element :elligible_young_people, '.govuk-summary-list__value', match: :first
    end
  end
end
