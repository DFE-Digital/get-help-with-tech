class BTWifiVoucher < ApplicationRecord
  belongs_to :distributed_to,
    class_name: 'ResponsibleBody',
    foreign_key: 'distributed_to_responsible_body_id',
    optional: true
end
