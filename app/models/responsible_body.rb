class ResponsibleBody < ApplicationRecord
  has_one :allocation_request
  has_one :bt_wifi_voucher_allocation
  has_many :bt_wifi_vouchers
end
