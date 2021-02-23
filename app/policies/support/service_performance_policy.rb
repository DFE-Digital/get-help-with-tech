class Support::ServicePerformancePolicy < ApplicationPolicy
  def index?
    user.is_support?
  end

  def mno_requests?
    user.is_support?
  end
end
