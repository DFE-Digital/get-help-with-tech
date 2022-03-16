require 'encryption_service'

class Download < ApplicationRecord
  DOWNLOAD_EXPIRY_TTL = 7.days

  belongs_to :user, optional: true

  def self.delete_expired_downloads!
    where('created_at <= ?', DOWNLOAD_EXPIRY_TTL.ago).delete_all
  end

  # copied from asset.rb - could be more DRY
  def self.secure_attr_accessor(*attributes)
    attributes.each do |attribute|
      define_method(attribute) do
        EncryptionService.decrypt(send(encrypted_field_symbol(attribute)))
      end

      define_method("#{attribute}=") do |plaintext|
        send("#{encrypted_field_symbol(attribute)}=", EncryptionService.encrypt(plaintext))
      end
    end
  end

  secure_attr_accessor :content

  def downloaded!
    update!(last_downloaded_at: Time.zone.now)
  end

private

  # copied from asset.rb - could be more DRY
  def encrypted_field_symbol(field_symbol)
    "encrypted_#{field_symbol}".to_sym
  end
end
