module PageObjects
  module ResponsibleBody
    class SchoolRow < SitePrism::Section
      element :title, 'td:nth-of-type(1)'
      element :who_will_order_devices, 'td:nth-of-type(2)'
      element :allocation, 'td:nth-of-type(3)'
      element :status, 'td:nth-of-type(4)'
    end

    class SchoolsPage < PageObjects::BasePage
      sections :specific_circumstances_school_rows, SchoolRow, '#specific-circumstances-schools tbody tr'
      sections :ordering_school_rows, SchoolRow, '#ordering-schools tbody tr'
      sections :fully_open_school_rows, SchoolRow, '#fully-open-schools tbody tr'
    end
  end
end
