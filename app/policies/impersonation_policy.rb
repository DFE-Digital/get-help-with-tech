class ImpersonationPolicy < ApplicationPolicy
  def create?
    user.third_line_role?
  end

  def destroy?
    user.third_line_role?
  end
end
