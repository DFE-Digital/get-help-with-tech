module SignInWithToken
  extend ActiveSupport::Concern

  included do
    validates :sign_in_token, uniqueness: true, allow_nil: true

    def generate_token!(ttl: nil)
      expiry_time = Time.zone.now.utc + effective_ttl(ttl).seconds
      update!(
        sign_in_token: SecureRandom.uuid,
        sign_in_token_expires_at: expiry_time,
      )
      sign_in_token
    end

    def effective_ttl(given_ttl)
      given_ttl || Settings.sign_in_token_ttl_seconds
    end

    def token_is_valid?(token:, identifier:)
      [
        token == sign_in_token,
        (sign_in_token_expires_at.present? && sign_in_token_expires_at >= Time.zone.now.utc),
        identifier == sign_in_identifier(token),
      ].all?
    end

    def token_is_valid_but_expired?(token:, identifier:)
      token == sign_in_token &&
        identifier == sign_in_identifier(token) &&
        sign_in_token_expires_at&.past?
    end

    def clear_token!
      update!(sign_in_token: nil, sign_in_token_expires_at: nil)
    end

    def sign_in_identifier(token)
      Digest::SHA256.hexdigest [email_address, token].join('-')
    end
  end
end
