module DeviceCount
  extend ActiveSupport::Concern

  included do
    def devices_available_to_order?
      devices_available_to_order.positive?
    end

    def devices_available_to_order
      [0, devices_available_to_order_or_over_ordered].max
    end

    private

    def devices_available_to_order_or_over_ordered
      cap.to_i - devices_ordered.to_i
    end
  end
end
