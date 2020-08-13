class APIAuthenticationService
  def self.identify_user(request)
    if (token = given_token(request))
      matched_token = APIToken.active.where(token: token).first
      matched_token&.user
    end
  end

  def self.authorization_given?(request)
    request.headers['Authorization'].present?
  end

  def self.given_token(request)
    request.headers['Authorization'].to_s.gsub(/Bearer\s+([^\s]*)$/, '\1')
  end
end
