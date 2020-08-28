class User < ApplicationRecord
  has_many :extra_mobile_data_requests, foreign_key: :created_by_user_id, inverse_of: :created_by_user, dependent: :destroy
  has_many :api_tokens, dependent: :destroy

  belongs_to :mobile_network, optional: true
  belongs_to :responsible_body, optional: true
  has_many :key_responsible_bodies, class_name: 'ResponsibleBody', foreign_key: :key_contact_id, inverse_of: :key_contact

  scope :approved, -> { where.not(approved_at: nil) }
  scope :signed_in_at_least_once, -> { where('sign_in_count > 0') }
  scope :responsible_body_users, -> { where.not(responsible_body: nil) }
  scope :mno_users, -> { where.not(mobile_network: nil) }

  validates :full_name,
            presence: true,
            length: { minimum: 2, maximum: 1024 }

  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 2, maximum: 1024 }

  before_validation :force_email_address_to_lowercase!

  include SignInWithToken

  def is_mno_user?
    mobile_network.present?
  end

  def is_responsible_body_user?
    responsible_body.present?
  end

  def update_sign_in_count_and_timestamp!
    update(sign_in_count: sign_in_count + 1, last_signed_in_at: Time.zone.now)
  end

  def seen_privacy_notice!
    update!(privacy_notice_seen_at: Time.zone.now)
  end

  def needs_to_see_privacy_notice?
    is_responsible_body_user? && !seen_privacy_notice?
  end

  def seen_privacy_notice?
    privacy_notice_seen_at.present?
  end

  def force_email_address_to_lowercase!
    self.email_address = email_address.downcase if email_address.present?
  end
end
