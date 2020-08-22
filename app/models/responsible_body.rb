class ResponsibleBody < ApplicationRecord
  has_one :bt_wifi_voucher_allocation
  has_many :bt_wifi_vouchers
  has_many :users
  has_many :extra_mobile_data_requests
  has_many :schools

  def humanized_type
    type.demodulize.underscore.humanize.downcase
  end

  def local_authority?
    type == 'LocalAuthority'
  end
end
