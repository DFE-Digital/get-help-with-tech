class GiasPolicy < ApplicationPolicy
  def readable?
    user.is_support? && user.third_line_role?
  end

  def editable?
    user.is_support? && user.third_line_role?
  end

  alias_method :index?, :readable?
  alias_method :show?, :readable?
  alias_method :update?, :editable?
end
