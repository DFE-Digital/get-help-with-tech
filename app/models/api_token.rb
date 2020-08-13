class APIToken < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :token, presence: true,
                    uniqueness: { scope: :user_id },
                    length: { minimum: 36, maximum: 36 }
  validates :name,  presence: true,
                    length: { minimum: 2, maximum: 64 },
                    uniqueness: { scope: :user_id }

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
    create(user: user)
  end
end
