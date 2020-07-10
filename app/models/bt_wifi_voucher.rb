class BTWifiVoucher < ApplicationRecord
  belongs_to :responsible_body, optional: true

  scope :unassigned, -> { where(responsible_body: nil) }
end
