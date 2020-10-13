module PageObjects
  module ResponsibleBody
    class SchoolOrderDevicesPage < PageObjects::BasePage
      set_url '/responsible-body/devices/schools/{urn}/order-devices'

      element :techsource_button, "a[href='/techsource-start']"
    end
  end
end
