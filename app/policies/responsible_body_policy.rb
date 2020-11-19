class ResponsibleBodyPolicy < SupportPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
