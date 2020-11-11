module PageObjects
  module Support
    class SchoolDetailsRow < SitePrism::Section
      element :key_element, 'dt'
      element :value_element, 'dd:nth-of-type(1)'
      element :action_element, 'dd:nth-of-type(2)'

      def key
        key_element.text
      end

      def value
        value_element.text
      end

      def follow_action_link
        action_element.find('a').click
      end
    end

    class SchoolDetailsSummaryList < SitePrism::Section
      sections :rows, SchoolDetailsRow, '.govuk-summary-list__row'

      def [](key)
        rows.find { |row| row.key == key }
      end
    end

    class SchoolDetailsPage < PageObjects::BasePage
      set_url '/support/schools/{urn}'

      elements :school_details_rows, '.school-details-summary-list .govuk-summary-list__row'
      section :school_details, SchoolDetailsSummaryList, '.school-details-summary-list'

      element :contacts, 'table#contacts'
      element :invite_a_new_user, 'a', text: 'Invite a new user'
    end
  end
end
