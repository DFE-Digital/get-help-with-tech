class SchoolPolicy < SupportPolicy
  class Scope < Scope
    def resolve
      if user.is_computacenter? || user.is_support?
        scope.all
      else
        raise 'Unexpected user type in school policy scope'
      end
    end
  end

  alias_method :search?, :readable?
  alias_method :results?, :readable?
  alias_method :invite?, :editable?
  alias_method :confirm_invitation?, :editable?

  def update_computacenter_reference?
    user.is_computacenter?
  end
end
