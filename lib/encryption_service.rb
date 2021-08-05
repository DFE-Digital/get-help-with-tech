class EncryptionService
  # for our enviornments, generate one-off environment variables:
  #
  # * GHWT__DATABASE_FIELD_ENCRYPTION__KEY
  # * GHWT__DATABASE_FIELD_ENCRYPTION__SALT
  #
  # with `SecureRandom.hex(12)` or suchlike

  def initialize
    @key = ActiveSupport::KeyGenerator.new(
      ENV.fetch('GHWT__DATABASE_FIELD_ENCRYPTION__KEY'),
    ).generate_key(
      ENV.fetch('GHWT__DATABASE_FIELD_ENCRYPTION__SALT'),
      ActiveSupport::MessageEncryptor.key_len,
    )

    freeze
  end

  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  def self.encrypt(plaintext)
    new.encrypt_and_sign(plaintext)
  end

  def self.decrypt(ciphertext)
    new.decrypt_and_verify(ciphertext)
  end

private

  def encryptor
    ActiveSupport::MessageEncryptor.new(@key)
  end
end
