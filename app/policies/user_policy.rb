class UserPolicy < SupportPolicy
  class Scope < Scope
    def resolve
      if user.is_computacenter?
        scope.where.not(privacy_notice_seen_at: nil)
      elsif user.is_support?
        scope.all
      else
        raise 'Unexpected user type in user policy scope'
      end
    end
  end

  alias_method :search?, :readable?
  alias_method :results?, :readable?
  alias_method :export?, :readable?
  alias_method :confirm_destroy?, :editable?
  alias_method :update_schools?, :editable?
end
