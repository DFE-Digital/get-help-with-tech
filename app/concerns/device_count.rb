module DeviceCount
  extend ActiveSupport::Concern

  included do
    def has_devices_available_to_order?
      available_devices_count.positive?
    end

    def available_devices_count
      [0, (cap.to_i - devices_ordered.to_i)].max
    end
  end
end
