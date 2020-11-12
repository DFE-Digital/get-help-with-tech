class UserPolicy < SupportPolicy
  alias_method :search?, :readable?
  alias_method :results?, :readable?
end
