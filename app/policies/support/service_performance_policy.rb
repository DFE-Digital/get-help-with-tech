class Support::ServicePerformancePolicy < ApplicationPolicy
  def index?
    user.is_support?
  end
end
