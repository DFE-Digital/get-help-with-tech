class AllocationRequestForm
  include ActiveModel::Model

  attr_accessor :user, :allocation_request

  validates_presence_of :user, :allocation_request

  def initialize(user: nil, allocation_request: nil)
    @user = user || User.new
    @allocation_request = allocation_request || AllocationRequest.new
    populate_from_user!
    populate_from_allocation_request!
  end

  def self.from_params(params)
    new(
      user: User.new(params[:user]),
      allocation_request: AllocationRequest.new(params[:allocation_request])
    )
  end

  def allocation_request_attributes=(attributes)
    @allocation_request ||= []
    attributes.each do |i, allocation_request_params|
      @allocation_request = AllocationRequest.new(allocation_request_params)
    end
  end

  def save!
    @user.save!
    @allocation_request.save!
  end

private

  def populate_from_user!
    @user_id = @user.id
    @user_name = @user.full_name
    @user_email = @user.email_address
    @user_organisation = @user.organisation
  end

  def populate_from_allocation_request!
    @number_eligible = @allocation_request.number_eligible
    @number_eligible_with_hotspot_access = @allocation_request.number_eligible_with_hotspot_access
  end
end
