module PageObjects
  module ResponsibleBody
    class SchoolsPage < PageObjects::BasePage
      elements :school_rows, '#schools tbody tr'
    end
  end
end
