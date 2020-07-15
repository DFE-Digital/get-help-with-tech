class BTWifiVoucher < ApplicationRecord
  INITIAL_TOTAL_ALLOCATION = 10_000

  belongs_to :responsible_body, optional: true

  scope :unassigned, -> { where(responsible_body: nil) }

  include ExportableAsCsv

  def self.exportable_attributes
    {
      username: 'Username',
      password: 'Password',
    }
  end

  def self.assign(number, to:)
    unassigned
      .take(number)
      .map { |bt_wifi_voucher| bt_wifi_voucher.update(responsible_body: to) }
  end
end
