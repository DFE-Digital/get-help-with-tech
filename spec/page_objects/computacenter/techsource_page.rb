module PageObjects
  module Computacenter
    class TechSourcePage < PageObjects::BasePage
      set_url '/computacenter/techsource'

      element :bulk_email_input, '#bulk-techsource-form-emails-field'
      element :continue, 'input[value=Continue]'
    end
  end
end
