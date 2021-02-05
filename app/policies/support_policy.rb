class SupportPolicy < ApplicationPolicy
  def readable?
    user.is_support? || user.is_computacenter?
  end

  def editable?
    user.is_support?
  end

  alias_method :index?, :readable?
  alias_method :show?, :readable?
  alias_method :schools?, :readable?
  alias_method :technical_support?, :editable?
  alias_method :feature_flags?, :editable?
  alias_method :macros?, :readable?

  alias_method :new?, :editable?
  alias_method :create?, :editable?
  alias_method :edit?, :editable?
  alias_method :update?, :editable?
  alias_method :destroy?, :editable?
end
