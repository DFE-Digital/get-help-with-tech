class ResponsibleBody < ApplicationRecord
  has_one :allocation_request
  has_many :bt_wifi_vouchers, foreign_key: :distributed_to_responsible_body_id
  has_many :users
end
