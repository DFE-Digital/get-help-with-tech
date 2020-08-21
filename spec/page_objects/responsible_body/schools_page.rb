module PageObjects
  module ResponsibleBody
    class SchoolRow < SitePrism::Section
      element :title, 'td:nth-of-type(1)'
    end

    class SchoolsPage < PageObjects::BasePage
      sections :school_rows, SchoolRow, '#schools tbody tr'
    end
  end
end
