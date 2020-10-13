module PageObjects
  module ResponsibleBody
    class SchoolPage < PageObjects::BasePage
      set_url '/responsible-body/devices/schools{/urn}'

      section :school_details, '.school-details-summary-list dl' do
      end
    end
  end
end
