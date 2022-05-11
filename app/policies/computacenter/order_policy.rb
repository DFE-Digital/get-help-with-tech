class Computacenter::OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none if user.nil?

      return scope.all if user.is_support? || user.is_computacenter?

      scope.where(id: user.orders.pluck(:id))
    end
  end
end
