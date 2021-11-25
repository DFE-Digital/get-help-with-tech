module PageObjects
  module ResponsibleBody
    class SchoolRow < SitePrism::Section
      element :title, 'td:nth-of-type(1)'
      element :allocation, 'td:nth-of-type(2)'
      element :devices_ordered, 'td:nth-of-type(3)'
      element :who_will_order_devices, 'td:nth-of-type(4)'
    end

    class SchoolsPage < PageObjects::BasePage
      sections :specific_circumstances_school_rows, SchoolRow, '#specific-circumstances-schools tbody tr'
      sections :ordering_school_rows, SchoolRow, '#ordering-schools tbody tr'
      sections :cannot_order_yet_school_rows, SchoolRow, '#cannot-order-yet-schools tbody tr'
    end
  end
end
