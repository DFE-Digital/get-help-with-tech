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
  alias_method :history?, :editable?

  def update_computacenter_reference?
    user.is_computacenter?
  end

  def update_address?
    user.third_line_role?
  end

  def update_name?
    user.third_line_role?
  end

  def update_responsible_body?
    user.is_support? && user.third_line_role?
  end
end
