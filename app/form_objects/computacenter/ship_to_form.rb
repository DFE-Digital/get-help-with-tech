class Computacenter::ShipToForm
  include ActiveModel::Model

  attr_accessor :ship_to, :school

  validates :ship_to, numericality: { only_integer: true, greater_than: 0, message: 'Ship To must be a number greater than zero' }

  def initialize(params = {})
    super(params)
  end
end
