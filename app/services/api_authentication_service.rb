class APIAuthenticationService
  def self.identify_user(token)
    APIToken.active.where(token: token).first&.user
  end
end
