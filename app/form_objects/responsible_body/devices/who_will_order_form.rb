class ResponsibleBody::Devices::WhoWillOrderForm
  include ActiveModel::Model

  attr_accessor :who_will_order

  validates :who_will_order, inclusion: %w[responsible_body schools]
end
