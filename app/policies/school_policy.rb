class SchoolPolicy < SupportPolicy
  alias_method :search?, :readable?
  alias_method :results?, :readable?
  alias_method :invite?, :editable?
  alias_method :confirm_invitation?, :editable?
end
