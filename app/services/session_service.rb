class SessionService
  def self.send_magic_link_email!(email_address)
    if (user = find_user_by_email(email_address))
      user.generate_token!
      logger.debug "found user #{user.id} - #{user.email_address}, granted token #{user.sign_in_token}"
      user.sign_in_token
    else
      # silently ignore an incorrect email, to avoid inadvertently
      # exposing a find-someones-email-address vector
      logger.warn "incorrect email address entered: #{email_address} - ignoring"
      nil
    end
  end

  def self.validate_token!(token:, identifier:)
    user = User.where(sign_in_token: token).first
    if user && user.token_is_valid?(token: token, identifier: identifier)
      user.clear_token!
      user
    else
      raise ArgumentError, 'token & id combination not recognised'
    end
  end

  def self.logger
    @logger ||= Rails.logger
  end

  # Will expand to cover MNO / MVNO and DfE users too
  def self.find_user_by_email(email_address)
    User.where(email_address: email_address).first
  end
end
