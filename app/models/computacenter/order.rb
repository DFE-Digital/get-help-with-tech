class Computacenter::Order < ApplicationRecord
  belongs_to :raw_order, class_name: 'Computacenter::RawOrder', inverse_of: :order
end
