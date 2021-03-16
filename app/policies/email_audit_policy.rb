class EmailAuditPolicy < SupportPolicy
  def index?
    user.is_support?
  end
end
