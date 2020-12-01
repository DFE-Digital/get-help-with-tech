module DeviceType
  extend ActiveSupport::Concern

  included do
    enum device_type: {
      'coms_device': 'coms_device',
      'std_device': 'std_device',
    }

    def device_type_name
      case device_type
      when 'coms_device'
        'router'
      else
        'device'
      end
    end
  end
end
