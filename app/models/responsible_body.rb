class ResponsibleBody < ApplicationRecord
  has_one :bt_wifi_voucher_allocation
  has_many :bt_wifi_vouchers
  has_many :users
  has_many :extra_mobile_data_requests
end
