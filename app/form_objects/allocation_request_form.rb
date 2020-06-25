class AllocationRequestForm
  include ActiveModel::Model

  attr_accessor :number_eligible,
                :number_eligible_with_hotspot_access,
                :allocation_request

  validates :number_eligible, numericality: { only_integer: true, minimum: 0, maximum: 10_000, message: 'Please tell us how many young people are eligible, for example 27' }
  validates :number_eligible_with_hotspot_access, numericality: { only_integer: true, minimum: 0, maximum: 10_000, message: 'Please tell us how many eligible young people can access a BT hotspot, for example 12' }
  validate  :number_eligible_with_hotspot_access_is_not_more_than_number_eligible

  def initialize(opts = {})
    @allocation_request = opts[:allocation_request] || AllocationRequest.new(opts)
    @number_eligible = opts[:number_eligible] || @allocation_request.number_eligible
    @number_eligible_with_hotspot_access = opts[:number_eligible_with_hotspot_access] || @allocation_request.number_eligible_with_hotspot_access
  end

  def save!
    @allocation_request ||= construct_allocation_request
    validate!
    @allocation_request.save!
  end

private

  def number_eligible_with_hotspot_access_is_not_more_than_number_eligible
    if number_eligible.to_i < number_eligible_with_hotspot_access.to_i
      message = 'The number of eligible young people who can access a BT hotspot cannot be more than the total number of eligible young people'
      errors.add(:number_eligible_with_hotspot_access, message)
    end
  end

  def construct_allocation_request
    AllocationRequest.new(
      number_eligible: @number_eligible,
      number_eligible_with_hotspot_access: @number_eligible_with_hotspot_access,
    )
  end
end
