class ChromebookPolicy < ApplicationPolicy
  def edit?
    user.is_support? || user.is_computacenter?
  end

  def update?
    user.is_support? || user.is_computacenter?
  end
end
