class ResponsibleBody::BasePolicy < ApplicationPolicy
  def create?
    if user.is_support? || user.is_computacenter?
      false
    else
      true
    end
  end

  def update?
    if user.is_support? || user.is_computacenter?
      false
    else
      true
    end
  end
end
