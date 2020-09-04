class User < ApplicationRecord
  has_paper_trail

  has_many :extra_mobile_data_requests, foreign_key: :created_by_user_id, inverse_of: :created_by_user, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_one :school_welcome_wizard, dependent: :destroy

  belongs_to :mobile_network, optional: true
  belongs_to :responsible_body, optional: true
  belongs_to :school, optional: true

  scope :approved, -> { where.not(approved_at: nil) }
  scope :signed_in_at_least_once, -> { where('sign_in_count > 0') }
  scope :responsible_body_users, -> { where.not(responsible_body: nil) }
  scope :from_responsible_body_in_devices_pilot, -> { joins(:responsible_body).where('responsible_bodies.in_devices_pilot = ?', true) }
  scope :from_responsible_body_in_connectivity_pilot, -> { joins(:responsible_body).where('responsible_bodies.in_connectivity_pilot = ?', true) }
  scope :mno_users, -> { where.not(mobile_network: nil) }
  scope :who_can_order_devices, -> { where(orders_devices: true) }

  validates :full_name,
            presence: true,
            length: { minimum: 2, maximum: 1024 }

  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 2, maximum: 1024 }

  validates :orders_devices,
            inclusion: { in: [true, false] },
            if: :is_school_user?

  validate :orders_devices_user_limit, if: :is_school_user?

  before_validation :force_email_address_to_lowercase!

  include SignInWithToken

  def is_mno_user?
    mobile_network.present?
  end

  def is_responsible_body_user?
    responsible_body.present?
  end

  def is_school_user?
    school.present?
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

  def orders_devices_user_limit
    if orders_devices? && school.users.who_can_order_devices.count >= 3
      errors.add(:orders_devices, I18n.t('activerecord.errors.models.user.attributes.orders_devices.user_limit'))
    end
  end

  def organisation_name
    mobile_network&.brand || \
      responsible_body&.local_authority_official_name || \
      responsible_body&.name || \
      school&.name || \
      (is_computacenter? && 'Computacenter') || \
      (is_support? && 'DfE Support')
  end
end
