class SessionService
  class TokenValidButExpired < StandardError; end

  class TokenNotRecognised < StandardError; end

  class InvalidTokenAndIdentifierCombination < StandardError; end

  DEFAULT_USER_TTL = 3600.seconds.freeze
  SUPPORT_USER_TTL = 7200.seconds.freeze
  TTLS = [DEFAULT_USER_TTL, SUPPORT_USER_TTL].freeze

  def self.send_magic_link_email!(email_address)
    if (user = find_user_by_lowercase_email(email_address))
      user.generate_token!
      logger.debug "found user #{user.id} - #{user.email_address}, granted token #{user.sign_in_token}"
      SignInTokenMailer.with(user:).sign_in_token_email.deliver_later
      user.sign_in_token
    else
      # silently ignore an incorrect email, to avoid inadvertently
      # exposing a find-someones-email-address vector
      logger.warn "incorrect email address entered: #{email_address} - ignoring"
      nil
    end
  end

  def self.validate_token!(token:, identifier:)
    user = User.find_by(sign_in_token: token)
    raise TokenNotRecognised if user.blank?

    if user.token_is_valid?(token:, identifier:)
      user
    elsif user.token_is_valid_but_expired?(token:, identifier:)
      raise TokenValidButExpired
    else
      raise InvalidTokenAndIdentifierCombination
    end
  end

  def self.logger
    @logger ||= Rails.logger
  end

  # Will expand to cover MNO / MVNO and DfE users too
  def self.find_user_by_lowercase_email(email_address)
    User.where('lower(email_address) = ?', email_address.downcase).first
  end

  def self.identify_user!(session)
    if is_signed_in?(session)
      user = User.find(session[:user_id])
      update_session!(session[:session_id], ttl_for_user(user))
      user
    end
  end

  def self.ttl_for_user(user)
    if user.is_support? || user.is_computacenter?
      SUPPORT_USER_TTL
    else
      DEFAULT_USER_TTL
    end
  end

  def self.is_signed_in?(session)
    session[:user_id].present? && validate_session!(session[:session_id])
  end

  def self.validate_session!(session_id)
    db_session = Session.where(id: session_id).first
    if db_session
      if db_session.expired?
        destroy_session!(session_id)
        false
      else
        true
      end
    else
      false
    end
  end

  def self.create_session!(session_id:, user:)
    Session.create!(id: session_id, expires_at: Time.zone.now.utc + ttl_for_user(user))
    user.update_sign_in_count_and_timestamp!
  end

  def self.update_session!(session_id, ttl)
    Session.where(id: session_id).update_all(updated_at: Time.zone.now.utc, expires_at: Time.zone.now.utc + ttl)
  end

  def self.destroy_session!(session_id)
    Session.where(id: session_id).destroy_all
  end
end
