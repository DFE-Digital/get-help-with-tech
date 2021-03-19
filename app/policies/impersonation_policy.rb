class ImpersonationPolicy < ApplicationPolicy
  def create?
    return false if user.is_computacenter?

    user.is_support?
  end

  def destroy?
    return false if user.is_computacenter?

    user.is_support?
  end
end
