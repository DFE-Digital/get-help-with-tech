class SlugChecksumService
  # for our environments, generate one-off environment variables:
  #
  # * GHWT__SLUG_CHECKSUM_SECRET
  #
  # with `SecureRandom.hex(24)` or suchlike

  def self.checksum(model_id)
    secret = Settings.slug_checksum_secret
    Digest::SHA1.hexdigest("#{secret}--#{model_id}")
  end

  def self.verify_uid(uid)
    model_id, checksum = uid.split('-')
    checksum(model_id) == checksum ? model_id : nil
  end
end
