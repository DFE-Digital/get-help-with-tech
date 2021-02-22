class ExtraMobileDataRequestPolicy < SupportPolicy
  class Scope < Scope
    def resolve
      if user.is_support? && !user.is_computacenter?
        scope.all
      else
        raise 'Unexpected user type in extra_mobile_data_request policy scope'
      end
    end
  end

  def readable?
    user.is_support? && !user.is_computacenter?
  end

  def editable?
    false
  end

  alias_method :index?, :readable?
  alias_method :show?, :readable?

  alias_method :new?, :editable?
  alias_method :create?, :editable?
  alias_method :edit?, :editable?
  alias_method :update?, :editable?
  alias_method :destroy?, :editable?
end
