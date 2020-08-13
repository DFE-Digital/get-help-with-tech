class APIToken < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :token, presence: { message: I18n.t('activerecord.errors.models.api_token.token.blank') },
                    uniqueness: { scope: :user_id },
                    length: { minimum: 36, maximum: 36 }
  validates :name,  presence: { message: I18n.t('activerecord.errors.models.api_token.name.blank') },
                    length: { minimum: 2, maximum: 64 },
                    uniqueness: { scope: :user_id, message: I18n.t('activerecord.errors.models.api_token.name.uniqueness') }

  before_validation :fill_in_defaults!

  enum status: {
    active: 'active',
    revoked: 'revoked',
  }

  def generate_token!
    self.token = SecureRandom.uuid
  end

  def fill_in_defaults!
    generate_token! if token.blank?
    self.status ||= APIToken.statuses[:active]
  end

  def self.generate!(user)
    token = create(user: user)
    token
  end
end
