class AllocationRequestForm
  include ActiveModel::Model

  attr_accessor :user, :allocation_request

  validates_presence_of :user, :allocation_request

  def initialize(user: nil, allocation_request: nil)
    @user = user || User.new
    @allocation_request = allocation_request || AllocationRequest.new(created_by_user: @user)
  end
  #
  # def allocation_request_attributes=(attributes)
  #   @allocation_request ||= []
  #   attributes.each do |i, allocation_request_params|
  #     @allocation_request = AllocationRequest.new(allocation_request_params)
  #   end
  # end

  def save!
    @user.save!
    @allocation_request.created_by_user = @user
    @allocation_request.save!
  end

end
