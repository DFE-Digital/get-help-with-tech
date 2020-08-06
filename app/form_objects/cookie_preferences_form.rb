class CookiePreferencesForm
  include ActiveModel::Model

  attr_accessor :cookie_consent

  validates :cookie_consent,
            presence: { message: 'Choose whether you consent to analytics cookies' },
            inclusion: { in: ['yes', 'no'], message: 'Choose yes or no' }

  def self.cookie_consent_options
    [
      OpenStruct.new( value: 'yes', label: 'Yes, opt-in to Google Analytics cookies' ),
      OpenStruct.new( value: 'no', label: 'No, do not track my website usage' ),
    ]
  end
end
