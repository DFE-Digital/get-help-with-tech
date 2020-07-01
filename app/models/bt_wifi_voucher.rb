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

  def self.grouped_by_recipient_responsible_body
    where.not(distributed_to: nil)
      .includes(:distributed_to)
      .group_by(&:distributed_to)
  end
end
