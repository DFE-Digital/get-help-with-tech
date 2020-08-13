class APIToken < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :token, presence: { message: I18n.t('activerecord.errors.models.api_token.token.blank') },
                    uniqueness: { scope: :user_id },
                    length: { minimum: 36, maximum: 36 }
  validates :name,  presence: { message: I18n.t('activerecord.errors.models.api_token.name.blank') },
                    length: { minimum: 2, maximum: 64 }

  before_validation :fill_in_defaults!

  enum status: {
    active: 'active',
    revoked: 'revoked'
  }

  def generate_token!
    self.token = SecureRandom.uuid
  end

  def fill_in_defaults!
    generate_token! unless token.present?
    self.status ||= APIToken.statuses[:active]
  end

  def self.generate!(user)
    token = new(
      status: 'active',
      user:    user
    )
    token.generate_token!
    token.save!
    token
  end
end
