class User < ApplicationRecord
  has_many :extra_mobile_data_requests, foreign_key: :created_by_user_id, inverse_of: :created_by_user, dependent: :destroy

  belongs_to :mobile_network, optional: true
  belongs_to :responsible_body, optional: true

  scope :approved, -> { where.not(approved_at: nil) }

  validates :full_name,
            presence: { message: 'Enter your full name' },
            length: { minimum: 2, maximum: 1024 }

  validates :email_address,
            presence: { message: 'Enter an email address in the correct format, like name@example.com' },
            uniqueness: { message: 'Email address has already been used' },
            length: { minimum: 2, maximum: 1024 }

  include SignInWithToken

  def is_mno_user?
    mobile_network.present?
  end

  def is_responsible_body_user?
    responsible_body.present?
  end

  def is_dfe?
    email_address.present? && email_address.match?(/[\.@]education.gov.uk$/)
  end

  def update_sign_in_count_and_timestamp!
    update(sign_in_count: sign_in_count + 1, last_signed_in_at: Time.zone.now)
  end
end
