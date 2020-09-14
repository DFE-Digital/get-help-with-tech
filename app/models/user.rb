class User < ApplicationRecord
  has_paper_trail

  has_many :extra_mobile_data_requests, foreign_key: :created_by_user_id, inverse_of: :created_by_user, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :user_organisations
  has_many :schools, through: :user_organisations, source: :organisation, source_type: "School"
  has_many :responsible_bodies, through: :user_organisations, source: :organisation, source_type: "ResponsibleBody"
  has_many :school_welcome_wizards, dependent: :destroy

  belongs_to :mobile_network, optional: true

  scope :approved, -> { where.not(approved_at: nil) }
  scope :signed_in_at_least_once, -> { where('sign_in_count > 0') }
  scope :responsible_body_users, -> { where.not(responsible_body: nil) }
  scope :from_responsible_body_in_devices_pilot, -> { joins(:responsible_bodies).where('responsible_bodies.in_devices_pilot = ?', true) }
  scope :from_responsible_body_in_connectivity_pilot, -> { joins(:responsible_bodies).where('responsible_bodies.in_connectivity_pilot = ?', true) }
  scope :mno_users, -> { where.not(mobile_network: nil) }
  scope :who_can_order_devices, -> { where(orders_devices: true) }
  scope :who_have_seen_privacy_notice, -> { where.not(privacy_notice_seen_at: nil) }

  validates :full_name,
            presence: true,
            length: { minimum: 2, maximum: 1024 }

  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 2, maximum: 1024 },
            email_address: true

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
    responsible_bodies.size > 0
  end

  def is_school_user?
    schools.size > 0
  end

  def update_sign_in_count_and_timestamp!
    update(sign_in_count: sign_in_count + 1, last_signed_in_at: Time.zone.now)
  end

  def seen_privacy_notice!
    update!(privacy_notice_seen_at: Time.zone.now)
  end

  def needs_to_see_privacy_notice?
    (is_responsible_body_user? || is_school_user?) && !seen_privacy_notice?
  end

  def seen_privacy_notice?
    privacy_notice_seen_at.present?
  end

  def force_email_address_to_lowercase!
    self.email_address = email_address.downcase if email_address.present?
  end

  def orders_devices_user_limit
    if orders_devices? && schools.any? { |school| school.users.who_can_order_devices.count >= 3 }
      errors.add(:orders_devices, I18n.t('activerecord.errors.models.user.attributes.orders_devices.user_limit'))
    end
  end

  def organisation_name
    mobile_network&.brand || \
      responsible_bodies.first&.local_authority_official_name || \
      responsible_bodies.first&.name || \
      schools.first&.name || \
      (is_computacenter? && 'Computacenter') || \
      (is_support? && 'DfE Support')
  end

  def first_name
    (full_name || '').strip.split(' ').first.to_s
  end

  def last_name
    (full_name || '').strip.split(' ').last.to_s
  end

  def effective_responsible_body
    responsible_body || school&.responsible_body
  end

  def school_welcome_wizard_for(school)
    school_welcome_wizards.find_by_school_id(school.id)
  end
end
