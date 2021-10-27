module DeviceType
  extend ActiveSupport::Concern

  included do
    enum device_type: {
      'coms_device': 'coms_device',
      'std_device': 'std_device',
    }

    def device_type_name
      device_type == 'coms_device' ? 'router' : 'device'
    end
  end
end
