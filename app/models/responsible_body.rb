class ResponsibleBody < ApplicationRecord
  has_one :allocation_request
  has_many :bt_wifi_vouchers
end
