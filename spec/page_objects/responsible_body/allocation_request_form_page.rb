module PageObjects
  module ResponsibleBody
    class AllocationRequestFormPage < PageObjects::BasePage
      set_url '/responsible_body/eligibility-and-hotspots'

      element :heading, 'h1'

      element :number_eligible, '#allocation-request-number-eligible-field'
      element :number_eligible_with_hotspot_access, '#allocation-request-number-eligible-with-hotspot-access-field'

      element :continue_button, 'input[type="submit"]'
    end
  end
end
