class DonatedDeviceSelectionForm
  # include ActiveModel::Model

  STATES = %i[
    select_devices
    select_units
  ].freeze

  # attr_accessor :state, :device_types, :units
  attr_accessor :donated_device_request

  validates :device_types, presence: { message: 'Tell us which devices you will accept' }
  validates :units, presence: { message: 'Tell us how many devices you want' }, if: -> { select_units? }
  validate :valid_devices_selected

  def initialize(donated_device_request:)
    @donated_device_request = donated_device_request
  end

  def available_device_types
    DonatedDeviceRequest::DEVICE_TYPES.map do |dt|
      OpenStruct.new(id: dt,
                     name: device_label(dt))
    end
  end

  def device_amount_options
    (1..4).map do |amount|
      OpenStruct.new(value: amount,
                     label: "#{amount * 5} devices")
    end
  end

  def select_devices?
    state.to_sym == :select_devices
  end

  def select_units?
    state.to_sym == :select_units
  end

private

  def valid_devices_selected
    unless device_types.nil?
      errors.add(:device_types, 'Your selection includes an invalid device type') unless device_types.compact_blank.all? { |d| DonatedDeviceRequest::DEVICE_TYPES.include?(d) }
    end
  end

  def device_label(device_type)
    I18n.t(device_type.to_s.underscore, scope: 'page_titles.school.donated_devices.interest.device_types.device_labels')
  end
end
