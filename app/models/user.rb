class User < ApplicationRecord
  has_paper_trail

  has_many :extra_mobile_data_requests, foreign_key: :created_by_user_id, inverse_of: :created_by_user, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :school_welcome_wizards, dependent: :destroy

  belongs_to :mobile_network, optional: true
  belongs_to :responsible_body, optional: true

  has_many :user_schools, dependent: :destroy,
                          after_add: :generate_user_change_if_needed!,
                          after_remove: [
                            :generate_user_change_if_needed!,
                            ->(user, user_school) { user.destroy_school_welcome_wizard!(user_school.school) },
                          ]

  has_many :schools,  through: :user_schools,
                      after_add: :generate_user_change_if_needed!,
                      after_remove: [
                        :generate_user_change_if_needed!,
                        ->(user, school) { user.destroy_school_welcome_wizard!(school) },
                      ]

  scope :signed_in_at_least_once, -> { where('sign_in_count > 0') }
  scope :responsible_body_users, -> { where.not(responsible_body: nil) }
  scope :from_responsible_body_in_connectivity_pilot, -> { joins(:responsible_body).where('responsible_bodies.in_connectivity_pilot = ?', true) }
  scope :mno_users, -> { where.not(mobile_network: nil) }
  scope :who_can_order_devices, -> { where(orders_devices: true) }
  scope :with_techsource_account_confirmed, -> { where.not(techsource_account_confirmed_at: nil) }
  scope :who_have_seen_privacy_notice, -> { where.not(privacy_notice_seen_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :not_deleted, -> { where(deleted_at: nil) }

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

  after_save do
    generate_user_change_if_needed!
  end

  after_destroy do
    generate_user_change_if_needed!
  end

  def generate_user_change_if_needed!(_obj = nil)
    Computacenter::UserChangeGenerator.new(self).generate!
  end

  def destroy_school_welcome_wizard!(school)
    welcome_wizard_for(school)&.destroy!
  end

  def is_mno_user?
    mobile_network.present?
  end

  def is_responsible_body_user?
    responsible_body.present?
  end

  def is_school_user?
    school.present?
  end

  def has_multiple_schools?
    schools.size > 1
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
    if orders_devices?
      if (new_record? || orders_devices_changed?) && school.users.who_can_order_devices.count >= 3
        errors.add(:orders_devices, I18n.t('activerecord.errors.models.user.attributes.orders_devices.user_limit'))
      end
    end
  end

  def organisation_name
    mobile_network&.brand || \
      responsible_body&.local_authority_official_name || \
      (schools.size == 1 && school&.name) || \
      responsible_body&.name || \
      (is_computacenter? && 'Computacenter') || \
      (is_support? && 'DfE Support')
  end

  def first_name
    cleansed_full_name.split(' ').first.to_s
  end

  def last_name
    cleansed_full_name.split(' ').last.to_s
  end

  def effective_responsible_body
    responsible_body || school&.responsible_body
  end

  def effective_responsible_bodies
    user_schools.map { |us| us.school.responsible_body }.prepend(responsible_body).compact.uniq
  end

  def relevant_to_computacenter?
    seen_privacy_notice? && orders_devices?
  end

  def techsource_account_confirmed?
    techsource_account_confirmed_at.present?
  end

  def awaiting_techsource_account?
    orders_devices? && !techsource_account_confirmed?
  end

  def has_an_active_techsource_account?
    orders_devices? && techsource_account_confirmed?
  end

  def is_a_single_academy_trust_user?
    user_schools.size == 1 && responsible_body&.is_a_single_academy_trust? && school.responsible_body_id == responsible_body.id
  end

  # Wrapper methods to ease the transition from 'user belongs_to school',
  # to 'user has_many schools'
  def school
    user_schools.first&.school
  end

  def school_id
    school&.id
  end

  def school_id=(new_school_id)
    user_schools.delete_all
    schools << School.find(new_school_id) if new_school_id
  end

  def school=(new_school)
    user_schools.delete_all
    schools << new_school if new_school.present?
  end

  def welcome_wizard_for(school)
    school_welcome_wizards.find_by_school_id(school.id)
  end

  def schools_i_order_for
    if orders_devices?
      schools.that_will_order_devices + Array(responsible_body&.schools&.that_are_centrally_managed)
    else
      []
    end
  end

  def soft_deleted?
    deleted_at.present?
  end

private

  def cleansed_full_name
    (full_name || '')
      .strip
      .then { |str| str =~ /@/ ? full_name_from_email_address(str) : str }
      .gsub(/^(Mr|Mrs|Ms|Miss|Dr) /, '')
  end

  def full_name_from_email_address(string)
    local_part = string.split('@').first
    if local_part.include?('.')
      local_part.gsub('.', ' ').titleize
    else
      "#{local_part[0]} #{local_part[1..-1]}".titleize
    end
  end
end
