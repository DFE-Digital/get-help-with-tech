class AssetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.is_computacenter? ? scope.none : scope.all
    end
  end

  def show?
    !user.is_computacenter?
  end
end
