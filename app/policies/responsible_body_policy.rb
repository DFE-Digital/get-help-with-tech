class ResponsibleBodyPolicy < SupportPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def update_computacenter_reference?
    user.is_computacenter?
  end
end
