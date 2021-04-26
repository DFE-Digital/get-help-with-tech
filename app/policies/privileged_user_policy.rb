class PrivilegedUserPolicy < SupportPolicy
  def index?
    user.third_line_role?
  end

  def new?
    user.third_line_role?
  end

  def create?
    user.third_line_role?
  end

  def destroy?
    user.third_line_role?
  end

  def show?
    user.third_line_role?
  end
end
