class DonatedDeviceRequest < ApplicationRecord
  # Model no longer used - this model remains for access to data kept in the table

  DEVICE_TYPES = %w[
    windows
    chromebook
    android-tablet
    ipad
  ].freeze

  enum status: {
    complete: 'complete',
    incomplete: 'incomplete',
    opt_in_step: 'opt_in_step',
    schools_step: 'schools_step',
    devices_step: 'devices_step',
    units_step: 'units_step',
  }

  enum opt_in_choice: {
    single_school: 'single_school',
    some_schools: 'some_schools',
    all_schools: 'all_schools',
  }, _prefix: :opt_in

  belongs_to :responsible_body, optional: true
  belongs_to :user

  validate :units_are_present_and_in_range, if: -> { units_step? || complete? }
  validate :device_types_are_present_and_correct, if: -> { responsible_body.nil? || devices_step? || complete? }
  validates :opt_in_choice, presence: { message: 'Tell us which schools or colleges you want to opt in' }, if: -> { opt_in_step? }
  validates :schools, presence: { message: 'Tell us which schools or colleges you want to opt in' }, if: -> { responsible_body.nil? || schools_step? || complete? }

  def self.for_school(school)
    where('? = ANY(schools)', school.id)
  end

  def self.for_responsible_body(responsible_body)
    where(responsible_body:)
  end

  def mark_as_complete!
    update!(status: 'complete', completed_at: Time.zone.now)
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
    if device_types.blank?
      errors.add(:device_types, 'Tell us which devices you will accept')
    else
      errors.add(:device_types, 'includes an invalid device type') unless device_types.all? { |d| DEVICE_TYPES.include?(d) }
    end
  end
end
