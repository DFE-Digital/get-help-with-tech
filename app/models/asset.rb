require 'encryption_service'

class Asset < ApplicationRecord
  validates :serial_number, :department_sold_to_id, presence: true

  default_scope { order(:location) }

  def self.secure_attr_accessor(*attributes)
    attributes.each do |attribute|
      define_method(attribute) do
        EncryptionService.decrypt(send(encrypted_field_symbol(attribute)))
      end

      define_method("#{attribute}=") do |plaintext|
        send(:update!, encrypted_field_symbol(attribute) => EncryptionService.encrypt(plaintext))
      end
    end
  end

  secure_attr_accessor :bios_password, :admin_password, :hardware_hash

  scope :owned_by, lambda { |setting|
    if setting.is_a?(School)
      school_cc_reference = setting.computacenter_reference
      where(location_cc_ship_to_account: school_cc_reference)
    elsif setting.is_a?(ResponsibleBody)
      rb_cc_reference = setting.computacenter_reference
      self_managing_schools = setting.schools.to_a.select { |school| school.who_will_order_devices == 'school' }
      self_managing_school_cc_references = self_managing_schools.collect(&:computacenter_reference)

      where(department_sold_to_id: rb_cc_reference).or(where(location_cc_ship_to_account: self_managing_school_cc_references))
    else
      raise 'unknown educational setting type'
    end
  }

  def ==(other)
    self.class == other.class && tag == other.tag && serial_number == other.serial_number
  end

private

  def encrypted_field_symbol(field_symbol)
    "encrypted_#{field_symbol}".to_sym
  end
end
