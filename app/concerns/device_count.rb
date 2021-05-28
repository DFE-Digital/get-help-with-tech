module DeviceCount
  extend ActiveSupport::Concern

  included do
    def devices_available_to_order?
      devices_available_to_order.positive?
    end

    def devices_available_to_order
      [0, (cap.to_i - devices_ordered.to_i)].max
    end
  end
end
