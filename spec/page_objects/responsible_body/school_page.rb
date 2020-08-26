module PageObjects
  module ResponsibleBody
    class SchoolPage < PageObjects::BasePage
      element :school_details, '.school-details-summary-list dl'
    end
  end
end
