class DonatedDeviceRequest < ApplicationRecord
  DEVICE_TYPES = %w[
    windows
    chromebook
    android-tablet
    ipad
  ].freeze

  enum status: {
    complete: 'complete',
    incomplete: 'incomplete',
    units_step: 'units_step',
  }

  belongs_to :responsible_body
  belongs_to :user
  # belongs_to :school

  validates :units, presence: { message: 'Tell us how many devices you want' }, if: -> { units_step? || complete? }
  validates :device_types, presence: { message: 'Tell us which devices you will accept' }
  validates :schools, presence: true
  validate :validate_applicable_device_types

  def self.uncompleted
    where.not(status: 'complete')
  end

  def self.for_school(school)
    where('? = ANY(schools)', school.id)
  end

private

  def validate_applicable_device_types
    if device_types
      errors.add(:device_types, 'includes an invalid device type') unless device_types.all? { |d| DEVICE_TYPES.include?(d) }
    end
  end
end
