require 'encryption_service'

class Asset < ApplicationRecord
  UNLOCKABLE_MODEL_PATTERN = /\ADynabook R50/

  validates :serial_number, :department_sold_to_id, presence: true

  default_scope { order(:location) }

  include ExportableAsCsv

  SUPPORT_ATTRIBUTES = {
    serial_number: 'Serial/IMEI',
    model: 'Model',
    department: 'Local Authority/Academy Trust',
    location: 'School/College',
    department_sold_to_id: 'Sold To',
    location_cc_ship_to_account: 'Ship To',
    bios_password: 'BIOS Password',
    admin_password: 'Admin Password',
    hardware_hash: 'Hardware Hash',
  }.freeze

  NON_SUPPORT_ATTRIBUTES = SUPPORT_ATTRIBUTES.except(:department_sold_to_id, :location_cc_ship_to_account).freeze

  # Calls to .to_csv will return non-support attributes
  def self.exportable_attributes
    NON_SUPPORT_ATTRIBUTES
  end

  def self.to_support_csv
    class << self
      def exportable_attributes # rubocop:disable Lint/DuplicateMethods
        SUPPORT_ATTRIBUTES
      end
    end

    to_csv
  end

  def self.to_non_support_csv
    class << self
      def exportable_attributes # rubocop:disable Lint/DuplicateMethods
        NON_SUPPORT_ATTRIBUTES
      end
    end

    to_csv
  end

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

  secure_attr_accessor :bios_password, :admin_password, :hardware_hash

  scope :owned_by, lambda { |setting|
    if setting.is_a?(School)
      school_cc_reference = setting.computacenter_reference
      where(location_cc_ship_to_account: school_cc_reference)
    elsif setting.is_a?(ResponsibleBody)
      rb_cc_reference = setting.computacenter_reference
      self_managing_schools = setting.schools.to_a.select(&:orders_managed_by_school?)
      self_managing_school_cc_references = self_managing_schools.collect(&:computacenter_reference)

      where(department_sold_to_id: rb_cc_reference).or(where(location_cc_ship_to_account: self_managing_school_cc_references))
    else
      Asset.none
    end
  }

  scope :search_by_serial_numbers, ->(serial_numbers) { where(serial_number: serial_numbers) }

  def bios_unlockable?
    model.match?(UNLOCKABLE_MODEL_PATTERN)
  end

  def viewed?
    first_viewed_at.present?
  end

  def has_secret_information?
    [bios_password, admin_password, hardware_hash].any?(&:present?)
  end

  def ==(other)
    self.class == other.class && tag == other.tag && serial_number == other.serial_number
  end

private

  def encrypted_field_symbol(field_symbol)
    "encrypted_#{field_symbol}".to_sym
  end
end
