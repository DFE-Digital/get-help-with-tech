module PageObjects
  module Pages
    class HomePage < PageObjects::BasePage
      set_url '/'

      element :page_heading, 'h1.govuk-heading-xl'

      element :digital_platforms_page_link, '[data-service-section="digital-platforms"] a'
      element :edtech_landing_page_link, '[data-service-section="edtech"] a'
      element :guides_parents_carers_students_link, 'a[text()="Guides for parents, guardians, pupils and students"]'
    end
  end
end
