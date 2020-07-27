class RequireDFEUserConstraint
  def matches?(request)
    return false unless request.session[:user_id]

    user = SessionService.identify_user!(request.session)
    user && user.is_dfe?
  end
end
