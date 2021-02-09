module PageObjects
  module DevicesGuidance
    class HowToOrderPage < PageObjects::BasePage
      set_url '/devices/how-to-order'

      element :page_heading, 'h1.govuk-heading-xl'
      elements :steps, '.app-step-nav__step'
    end
  end
end
