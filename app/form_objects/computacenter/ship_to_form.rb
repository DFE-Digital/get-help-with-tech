class Computacenter::ShipToForm
  include ActiveModel::Model

  attr_accessor :change_ship_to, :ship_to, :school

  validates :ship_to, numericality: { only_integer: true, message: 'Ship To must be a number' }
  validates :change_ship_to, inclusion: { in: %w[yes no], message: 'Tell us whether the Ship To number needs to change' }

  def initialize(params = {})
    super(params)
  end
end
