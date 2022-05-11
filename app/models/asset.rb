require 'encryption_service'

class Asset < ApplicationRecord
  UNLOCKABLE_MODEL_PATTERN = /\ADynabook R50/

  belongs_to :setting, polymorphic: true, optional: true
  validates :serial_number, :department_sold_to_id, presence: true

  default_scope { order(:location) }
  scope :with_no_setting, -> { where(setting_id: nil) }

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

  def self.to_viewed_csv
    class << self
      def exportable_attributes # rubocop:disable Lint/DuplicateMethods
        { serial_number: 'serial_number', first_viewed_at: 'first_viewed_at' }
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

  def to_param
    "#{id}-#{SlugChecksumService.checksum(id)}"
  end

  secure_attr_accessor :bios_password, :admin_password, :hardware_hash

  scope :owned_by, lambda { |setting|
    return owned_by_school(setting) if setting.is_a?(School)
    return owned_by_rb(setting) if setting.is_a?(ResponsibleBody)

    Asset.none
  }

  scope :owned_by_rb, lambda { |rb|
    where(department_sold_to_id: rb.sold_to)
      .or(where(location_cc_ship_to_account: rb.schools.select(&:orders_managed_by_school?).map(&:ship_to)))
      .or(where(department_id: "SC#{rb.gias_id}"))
  }

  scope :owned_by_school, lambda { |school|
    where(location_cc_ship_to_account: school.ship_to)
      .or(where(department: school.name))
  }

  scope :search_by_serial_numbers, ->(serial_numbers) { where('serial_number ILIKE ANY (ARRAY[?])', serial_numbers) }

  scope :first_viewed_during_period, ->(period) { where(first_viewed_at: period) }

  def bios_unlockable?
    model.match?(UNLOCKABLE_MODEL_PATTERN)
  end

  def viewed?
    first_viewed_at.present?
  end

  def has_secret_information?
    [encrypted_bios_password, encrypted_admin_password, encrypted_hardware_hash].any?(&:present?)
  end

  def ==(other)
    self.class == other.class && tag == other.tag && serial_number == other.serial_number
  end

private

  def encrypted_field_symbol(field_symbol)
    "encrypted_#{field_symbol}".to_sym
  end
end
