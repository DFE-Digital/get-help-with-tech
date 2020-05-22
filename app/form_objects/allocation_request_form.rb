class AllocationRequestForm
  include ActiveModel::Model

  attr_accessor :user, :allocation_request

  validates_associated :user, :allocation_request
  validate :user_is_valid
  validate :allocation_request_is_valid

  def initialize(user: nil, allocation_request: nil)
    @user = user || User.new
    @allocation_request = allocation_request || AllocationRequest.new(created_by_user: @user)
  end

  def save!
    @user.save!

    @allocation_request.created_by_user = @user
    @allocation_request.save!
  end

private

  def user_is_valid
    errors.add(:user, 'is invalid') if user.invalid?
  end

  def allocation_request_is_valid
    errors.add(:allocation_request, 'is invalid') if allocation_request.invalid?
  end
end
