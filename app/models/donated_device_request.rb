class DonatedDeviceRequest < ApplicationRecord
  DEVICE_TYPES = %w[
    windows
    chromebook
    android-tablet
    ipad
  ].freeze

  belongs_to :user
  belongs_to :school

  validates :units, :device_types, presence: true
  validates :device_types, presence: { message: 'Tell us which devices you want' }
  validate :validate_applicable_device_types

private

  def validate_applicable_device_types
    if device_types
      errors.add(:device_types, 'includes an invalid device type') unless device_types.all? { |d| DEVICE_TYPES.include?(d) }
    end
  end
end
