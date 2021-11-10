module Computacenter
  class DevicesOrderedUpdate < ApplicationRecord
    self.table_name = 'computacenter_devices_ordered_updates'

    belongs_to :school, primary_key: :computacenter_reference,
                        foreign_key: :ship_to,
                        optional: true

    belongs_to :cap_usage_update_payload, class_name: 'Computacenter::API::CapUsageUpdatePayload', optional: true
  end
end
