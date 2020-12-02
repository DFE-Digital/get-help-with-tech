class Computacenter::SoldToForm
  include ActiveModel::Model

  attr_accessor :change_sold_to, :sold_to, :responsible_body

  validates :sold_to, numericality: { only_integer: true, message: 'Sold To must be a number' }
  validates :change_sold_to, inclusion: { in: %w[yes no], message: 'Tell us whether the Sold To number needs to change' }

  def initialize(params = {})
    super(params)
  end
end
