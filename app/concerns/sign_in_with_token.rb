module SignInWithToken
  extend ActiveSupport::Concern

  included do
    validates :sign_in_token, uniqueness: true, allow_nil: true

    def generate_token!
      update!(sign_in_token: SecureRandom.uuid)
      sign_in_token
    end

    def clear_token!
      update!(sign_in_token: nil)
    end

    def sign_in_identifier(token)
      Digest::SHA256.hexdigest [email_address, token].join('-')
    end
  end
end
