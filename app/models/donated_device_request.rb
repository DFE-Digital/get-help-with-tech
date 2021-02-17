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
    devices_step: 'devices_step',
    units_step: 'units_step',
  }

  belongs_to :responsible_body, optional: true
  belongs_to :user

  validate :units_are_present_and_in_range, if: -> { units_step? || complete? }
  validate :device_types_are_present_and_correct, if: -> { responsible_body.nil? || devices_step? || complete? }

  validates :schools, presence: true

  def self.uncompleted
    where.not(status: 'complete')
  end

  def self.for_school(school)
    where('? = ANY(schools)', school.id)
  end

  def self.for_responsible_body(responsible_body)
    where(responsible_body: responsible_body)
  end

private

  def units_are_present_and_in_range
    if units.nil? || units < 1 || units > 4
      message = if responsible_body.present?
                  'Tell us how many devices each school wants'
                else
                  'Tell us how many devices you want'
                end
      errors.add(:units, message)
    end
  end

  def device_types_are_present_and_correct
    if device_types.nil? || device_types.empty?
      errors.add(:device_types, 'Tell us which devices you want')
    else
      errors.add(:device_types, 'includes an invalid device type') unless device_types.all? { |d| DEVICE_TYPES.include?(d) }
    end
  end
end
