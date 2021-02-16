class DonatedDeviceInterestForm
  include ActiveModel::Model

  attr_accessor :device_interest

  validates :device_interest,
            presence: { message: 'Choose whether you are interested in this scheme' },
            inclusion: { in: %w[yes no], message: 'Choose yes or no' }

  def self.interest_options
    [
      OpenStruct.new(value: 'yes', label: 'Yes, tell me more'),
      OpenStruct.new(value: 'no', label: 'No, not at the moment'),
    ]
  end

  def self.confirmation_interest_options
    [
      OpenStruct.new(value: 'yes', label: 'Yes'),
      OpenStruct.new(value: 'no', label: "No, I'm not interested"),
    ]
  end

  def interested?
    device_interest == 'yes'
  end
end
