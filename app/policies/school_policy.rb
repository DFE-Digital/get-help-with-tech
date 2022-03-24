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

  def devices_orderable?
    responsible_body_user? || devolved_management_school_user?
  end

  def editable?
    false
  end

  def support_third_line_editable?
    false
  end

  alias_method :search?, :readable?
  alias_method :results?, :readable?
  alias_method :invite?, :editable?
  alias_method :confirm_invitation?, :editable?
  alias_method :history?, :editable?
  alias_method :update_address?, :support_third_line_editable?
  alias_method :update_headteacher?, :support_third_line_editable?
  alias_method :update_name?, :support_third_line_editable?
  alias_method :update_responsible_body?, :support_third_line_editable?

  def update_computacenter_reference?
    user.is_computacenter?
  end

private

  def devolved_management_school_user?
    record.orders_managed_by_school? && record.users.include?(user)
  end

  def responsible_body_user?
    user.responsible_body_id.present? && user.responsible_body_id == record.responsible_body_id
  end
end
