class BTWifiVoucher < ApplicationRecord
  belongs_to :responsible_body, optional: true
end
