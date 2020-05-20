class AllocationRequestForm
  include ActiveModel::Model

  attr_accessor :user_id, :user_name, :user_email, :user_organisation
  attr_accessor :number_eligible,
                :number_eligible_with_hotspot_access

  validates_presence_of :user_name, :user_email, :user_organisation

  def initialize(user: nil, allocation_request: nil)
    @user = user || User.new
    @allocation_request = allocation_request || AllocationRequest.new
    populate_from_user!
    populate_from_allocation_request!
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
