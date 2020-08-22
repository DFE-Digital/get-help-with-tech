module PageObjects
  module ResponsibleBody
    class SchoolRow < SitePrism::Section
      element :title, 'td:nth-of-type(1)'
      element :allocation, 'td:nth-of-type(2)'
      element :who_will_order_devices, 'td:nth-of-type(3)'
      element :status, 'td:nth-of-type(4)'
    end

    class SchoolsPage < PageObjects::BasePage
      sections :school_rows, SchoolRow, '#schools tbody tr'
    end
  end
end
