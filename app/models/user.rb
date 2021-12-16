class User < ApplicationRecord
  has_paper_trail

  CAN_ORDER_DEVICES_LIMIT = 3

  enum role: {
    no: 'no',
    third_line: 'third_line',
  }, _suffix: true

  has_many :extra_mobile_data_requests, foreign_key: :created_by_user_id, inverse_of: :created_by_user, dependent: :nullify
  has_many :api_tokens, dependent: :destroy
  has_many :school_welcome_wizards, dependent: :destroy
  has_many :invited_to_school_welcome_wizards, class_name: 'SchoolWelcomeWizard', foreign_key: 'invited_user_id', dependent: :nullify
  has_many :key_contact_for_responsible_bodies, class_name: 'ResponsibleBody', foreign_key: 'key_contact_id', dependent: :nullify
  has_many :email_audits, dependent: :destroy
  has_one :last_user_change, -> { order('created_at DESC').limit(1) }, class_name: 'Computacenter::UserChange'

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

  alias_method :rb, :responsible_body

  scope :signed_in_at_least_once, -> { where('sign_in_count > 0') }
  scope :responsible_body_users, -> { where.not(responsible_body: nil) }
  scope :from_responsible_body_or_schools, -> { left_joins(:user_schools).where('responsible_body_id IS NOT NULL or user_schools.id IS NOT NULL') }
  scope :not_deleted_from_responsible_body_or_schools, -> { not_deleted.from_responsible_body_or_schools }
  scope :mno_users, -> { where.not(mobile_network: nil) }
  scope :who_can_order_devices, -> { where(orders_devices: true) }
  scope :with_techsource_account_confirmed, -> { where.not(techsource_account_confirmed_at: nil) }
  scope :who_have_seen_privacy_notice, -> { where.not(privacy_notice_seen_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :search_by_email_address_or_full_name, lambda { |search_term|
    where('email_address ILIKE ? OR full_name ILIKE ?', "%#{search_term.strip}%", "%#{search_term.strip}%")
  }

  scope :linked_to_school, ->(school_ids) { manages_school(school_ids).or(manages_school_through_rb(school_ids)) }
  scope :manages_rb, ->(rb_ids) { where(responsible_body_id: rb_ids) }
  scope :manages_school_through_rb, ->(school_ids) { manages_rb(ResponsibleBody.where_school_id(school_ids)) }
  scope :manages_school, ->(school_ids) { left_joins(:user_schools).where(user_schools: { school_id: school_ids }) }

  def self.relevant_to_device_supplier
    where(is_computacenter: false, is_support: false).who_have_seen_privacy_notice.who_can_order_devices.not_deleted
  end

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

  delegate :name, to: :responsible_body, prefix: true, allow_nil: true

  def generate_user_change_if_needed!(_obj = nil)
    Computacenter::UserChangeGenerator.new(self).generate!
  end

  def destroy_school_welcome_wizard!(school)
    welcome_wizard_for(school)&.destroy!
  end

  def is_mno_user?
    mobile_network.present?
  end

  def responsible_body_user?
    responsible_body.present?
  end

  def is_school_user?
    school.present?
  end

  def la_funded_user?
    schools.la_funded_provision.any?
  end

  def iss_provision_user?
    schools.iss_provision.any?
  end

  def scl_provision_user?
    schools.scl_provision.any?
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
    (responsible_body_user? || is_school_user?) && !seen_privacy_notice?
  end

  def seen_privacy_notice?
    privacy_notice_seen_at.present?
  end

  def force_email_address_to_lowercase!
    self.email_address = email_address.downcase if email_address.present?
  end

  def orders_devices_user_limit
    if orders_devices? && ((new_record? || orders_devices_changed?) && school.users.who_can_order_devices.count >= CAN_ORDER_DEVICES_LIMIT)
      errors.add(:orders_devices, I18n.t('activerecord.errors.models.user.attributes.orders_devices.user_limit', limit: CAN_ORDER_DEVICES_LIMIT))
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

  def organisations
    [schools, responsible_body].flatten.compact
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
    user_schools.map { |us| us.school&.responsible_body }.prepend(responsible_body).compact.uniq
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

  def single_school_user?
    user_schools.size == 1 && (responsible_body&.single_academy_trust? || responsible_body&.further_education_college?) && school.responsible_body_id == responsible_body.id
  end

  def schools_sold_tos
    schools.map(&:responsible_body).uniq.map(&:computacenter_reference).compact
  end

  def sold_tos
    ([rb&.sold_to] + schools_sold_tos).flatten.compact.uniq
  end

  def ship_tos
    schools.pluck(:computacenter_reference).compact
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
    wizard = school_welcome_wizards.find_by_school_id(school.id)
    return wizard if wizard

    if school.la_funded_provision?
      school_welcome_wizards.create!(school: school, step: 'complete')
    else
      school_welcome_wizards.create!(school: school)
    end
  end

  def schools_i_order_for
    if orders_devices?
      schools.school_will_order_devices + Array(responsible_body&.schools&.responsible_body_will_order_devices)
    else
      []
    end
  end

  def soft_deleted?
    deleted_at.present?
  end

  def associated_schools
    scope = School.gias_status_open.distinct

    if school && responsible_body
      scope = scope.joins(:responsible_body, user_schools: [:user])
      scope = scope.where('user_schools.user_id = ? OR schools.responsible_body_id = ?', id, responsible_body.id)
    elsif school
      scope = scope.joins(user_schools: [:user])
      scope = scope.where('user_schools.user_id = ?', id)
    elsif responsible_body
      scope = scope.joins(:responsible_body)
      scope = scope.where('schools.responsible_body_id = ?', responsible_body.id)
    else
      scope = scope.none
    end

    scope
  end

  def privileges
    array = []

    array << :support_user if is_support?
    array << :third_line_support_user if third_line_role?
    array << :computacenter_user if is_computacenter?
    array << :mno_user if is_mno_user?

    array
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
