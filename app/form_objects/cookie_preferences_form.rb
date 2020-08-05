class CookiePreferencesForm
  include ActiveModel::Model

  attr_accessor :cookie_consent

  validates :cookie_consent,
            presence: { message: 'Choose whether you consent to analytics cookies' },
            inclusion: { in: [true, false], message: 'Choose yes or no' }
end
