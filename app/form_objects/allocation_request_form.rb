class AllocationRequestForm
  include ActiveModel::Model
  include InlineUser

  attr_accessor :full_name,
                :address,
                :postcode,
                :number_eligible,
                :number_eligible_with_hotspot_access,
                :allocation_request,
                :user

  validates :number_eligible, numericality: { only_integer: true, minimum: 0, maximum: 10000, message: 'Please tell us how many young people are eligible, for example 27' }
  validates :number_eligible_with_hotspot_access, numericality: { only_integer: true, minimum: 0, maximum: 10000, message: 'Please tell us how many eligible young people can access a BT hotspot, for example 12' }
  validate  :number_eligible_with_hotspot_access_is_not_more_than_number_eligible

  def initialize(user: nil, allocation_request: nil, params: {})
    @user = user
    @allocation_request = allocation_request
    
    populate_from_user! if user
    populate_from_allocation_request! if allocation_request
    populate_from_params!(params) unless params.empty?
  end

  def save!
    @user ||= construct_user
    @allocation_request ||= construct_allocation_request
    validate!
    @user.save!
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
      created_by_user: @user,
      number_eligible: @number_eligible,
      number_eligible_with_hotspot_access: @number_eligible_with_hotspot_access,
    )
  end

  def populate_from_params!(params={})
    @user ||= User.new
    params.each do |key, value|
      self.send("#{key}=", value)
    end
    @user.full_name = params[:user_name]
    @user.email_address = params[:user_email]
    @user.organisation = params[:user_organisation]

    @number_eligible = params[:number_eligible]
    @number_eligible_with_hotspot_access = params[:number_eligible_with_hotspot_access]
  end

  def populate_from_allocation_request!
    @number_eligible = @allocation_request.number_eligible
    @number_eligible_with_hotspot_access = @allocation_request.number_eligible_with_hotspot_access
  end
end
