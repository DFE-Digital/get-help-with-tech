class BTWifiVoucher < ApplicationRecord
  belongs_to :distributed_to,
    class_name: 'ResponsibleBody',
    foreign_key: 'distributed_to_responsible_body_id',
    optional: true

  def self.assign(number, to:)
    self.where(distributed_to: nil)
      .take(number)
      .map {|responsible_body| responsible_body.update(distributed_to: to, distributed_at: Time.zone.now) }
  end
end
