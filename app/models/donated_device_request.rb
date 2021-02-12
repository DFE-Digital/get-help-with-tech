class DonatedDeviceRequest < ApplicationRecord
  DEVICE_TYPES = %w[
    windows-laptop
    windows-tablet
    android-tablet
    chromebook
    ipad
  ].freeze

  belongs_to :user
  belongs_to :school

  validates :units, :device_types, presence: true
  validate :validate_applicable_device_types

private

  def validate_applicable_device_types
    errors.add(:device_types, 'includes an invalid device type') unless device_types.all? { |d| DEVICE_TYPES.include?(d) }
  end
end
