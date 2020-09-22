class Support::BulkAllocationForm
  include ActiveModel::Model

  attr_accessor :school_urns

  validates :school_urns, presence: { message: 'Tell us the schools with confirmed coronvirus restrictions' }

  def urn_list
    return [] if school_urns.empty?

    school_urns.split("\r\n").reject(&:blank?)
  end
end
