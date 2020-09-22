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

  after_save do |user|
    Computacenter::UserChange.read_from_version(user.versions.last)
  end

  after_destroy do |user|
    Computacenter::UserChange.read_from_version(user.versions.last)
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
    if orders_devices?
      if (new_record? || orders_devices_changed?) && school.users.who_can_order_devices.count >= 3
        errors.add(:orders_devices, I18n.t('activerecord.errors.models.user.attributes.orders_devices.user_limit'))
      end
    end
  end

  def organisation_name
    mobile_network&.brand || \
      responsible_body&.local_authority_official_name || \
      school&.name || \
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

  def relevant_to_computacenter?
    seen_privacy_notice? && orders_devices?
  end

  def hybrid?
    school_id && responsible_body_id
  end

  def hybrid_setup!
    return if responsible_body.blank?

    one_school = responsible_body.schools.count == 1
    only_user = responsible_body.users == [self]

    return unless one_school && only_user

    school = responsible_body.schools.first

    update!(school: school)
    contact = school.contacts.create!(email_address: email_address,
                                      full_name: full_name,
                                      role: :contact,
                                      phone_number: telephone)
    school.create_preorder_information!(who_will_order_devices: 'school',
                                        school_contact: contact,
                                        status: 'school_contacted')
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
