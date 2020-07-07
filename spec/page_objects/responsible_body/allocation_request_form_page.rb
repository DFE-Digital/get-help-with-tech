module PageObjects
  module ResponsibleBody
    class AllocationRequestFormPage < PageObjects::BasePage
      set_url '/responsible-body/eligibility-and-hotspots'

      element :heading, 'h1'

      element :error_summary, '.govuk-error-summary'

      element :number_eligible, '#allocation-request-number-eligible-field'
      element :number_eligible_with_hotspot_access, '#allocation-request-number-eligible-with-hotspot-access-field'

      element :number_eligible_with_error, '#allocation-request-number-eligible-field-error'
      element :number_eligible_with_hotspot_access_with_error, '#allocation-request-number-eligible-with-hotspot-access-field-error'

      element :continue_button, 'input[type="submit"]'
    end
  end
end
