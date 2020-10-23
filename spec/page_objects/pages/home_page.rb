module PageObjects
  module Pages
    class HomePage < PageObjects::BasePage
      set_url '/'

      element :page_heading, 'h1.govuk-heading-xl'

      element :edtech_landing_page_link, '[data-service-section="edtech"] a'
    end
  end
end
