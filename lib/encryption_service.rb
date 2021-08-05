class EncryptionService
  # for our environments, generate one-off environment variables:
  #
  # * GHWT__DATABASE_FIELD_ENCRYPTION__KEY
  # * GHWT__DATABASE_FIELD_ENCRYPTION__SALT
  #
  # with `SecureRandom.hex(12)` or suchlike

  def initialize
    @key = ActiveSupport::KeyGenerator.new(
      Settings.database_field_encryption.key,
    ).generate_key(
      Settings.database_field_encryption.salt,
      ActiveSupport::MessageEncryptor.key_len,
    )

    freeze
  end

  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  def self.encrypt(plaintext)
    plaintext.present? ? new.encrypt_and_sign(plaintext) : nil
  end

  def self.decrypt(ciphertext)
    ciphertext.present? ? new.decrypt_and_verify(ciphertext) : nil
  end

private

  def encryptor
    ActiveSupport::MessageEncryptor.new(@key)
  end
end
