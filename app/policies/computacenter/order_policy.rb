class Computacenter::OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none if user.nil?

      return scope.all if user.is_support? || user.is_computacenter?

      return scope.where(id: user.orders.pluck(:id)) if user.rb_level_access?

      scope.where(id: user.schools_orders.pluck(:id))
    end
  end
end
