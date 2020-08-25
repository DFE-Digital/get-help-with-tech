class RequireSupportUserConstraint
  def matches?(request)
    return false unless request.session[:user_id]

    user = SessionService.identify_user!(request.session)
    user&.is_support?
  end
end
