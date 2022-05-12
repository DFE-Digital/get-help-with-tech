class Computacenter::Order < ApplicationRecord
  belongs_to :raw_order,
             class_name: 'Computacenter::RawOrder',
             inverse_of: :order

  belongs_to :school,
             primary_key: :computacenter_reference,
             foreign_key: :ship_to,
             inverse_of: :orders,
             optional: true

  belongs_to :responsible_body,
             primary_key: :computacenter_reference,
             foreign_key: :sold_to,
             inverse_of: :rb_orders,
             optional: true

  scope :is_return, -> { where(is_return: true) }
  scope :is_not_return, -> { where(is_return: false) }
end
