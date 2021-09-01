class AssetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.nil? || user.is_computacenter? ? scope.none : scope.all
    end
  end

  def show?
    user.present? && !user.is_computacenter?
  end
end
