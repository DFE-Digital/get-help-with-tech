class APIToken < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :token, presence: true, uniqueness: true, length: { minimum: 36, maximum: 36 }

  enum status: {
    active: 'active',
    revoked: 'revoked'
  }

  def self.generate!(user)
    token = new(
      status: 'active',
      user:    user,
      token:   SecureRandom.uuid
    )
    token.save!
    token
  end
end
