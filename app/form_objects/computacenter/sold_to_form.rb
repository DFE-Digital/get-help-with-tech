class Computacenter::SoldToForm
  include ActiveModel::Model

  attr_accessor :sold_to, :responsible_body

  validates :sold_to, numericality: { only_integer: true, greater_than: 0, message: 'Sold To must be a number greater than zero' }

  def initialize(params = {})
    super(params)
  end
end
