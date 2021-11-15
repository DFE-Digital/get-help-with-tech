class School < ApplicationRecord
  has_paper_trail
  include PgSearch::Model
  include SchoolType

  DEVICE_TYPES = %i[laptop router].freeze

  belongs_to :responsible_body, inverse_of: :schools
  belongs_to :school_contact, optional: true

  has_many :contacts, class_name: 'SchoolContact', inverse_of: :school
  has_one :headteacher, -> { where role: 'headteacher' }, class_name: 'SchoolContact', inverse_of: :school
  has_many :user_schools
  has_many :users, through: :user_schools
  has_many :email_audits
  has_many :extra_mobile_data_requests
  has_many :school_links, dependent: :destroy
  has_many :devices_ordered_updates, class_name: 'Computacenter::DevicesOrderedUpdate',
                                     primary_key: :computacenter_reference,
                                     foreign_key: :ship_to
  has_many :cap_changes, dependent: :destroy, inverse_of: :school
  has_many :cap_update_calls, dependent: :destroy, inverse_of: :school

  validates :name, presence: true
  validates :preorder_status, presence: true

  pg_search_scope :matching_name_or_urn_or_ukprn_or_provision_urn, against: %i[name urn ukprn provision_urn], using: { tsearch: { prefix: true } }

  before_save :check_and_update_status_if_necessary
  before_create :set_computacenter_change
  after_update :maybe_generate_user_changes
  after_commit :refresh_preorder_status!, on: :create

  enum computacenter_change: {
    none: 'none',
    new: 'new',
    amended: 'amended',
    closed: 'closed',
  }, _prefix: true

  enum preorder_status: {
    needs_contact: 'needs_contact',
    needs_info: 'needs_info',
    ready: 'ready',
    school_will_be_contacted: 'school_will_be_contacted',
    school_contacted: 'school_contacted',
    school_ready: 'school_ready',
    rb_can_order: 'rb_can_order',
    school_can_order: 'school_can_order',
    ordered: 'ordered',
  }

  enum status: {
    open: 'open',
    closed: 'closed',
  }, _prefix: 'gias_status'

  enum order_state: {
    cannot_order: 'cannot_order',
    can_order_for_specific_circumstances: 'can_order_for_specific_circumstances',
    can_order: 'can_order',
  }

  enum who_will_order_devices: {
    school: 'school',
    responsible_body: 'responsible_body',
  }, _suffix: 'will_order_devices'

  scope :excluding_la_funded_provisions, -> { where.not(type: 'LaFundedPlace') }
  scope :further_education, -> { where(type: 'FurtherEducationSchool') }

  scope :has_fully_ordered_laptops, -> { where("raw_laptops_ordered > 0 AND (order_state = 'cannot_order' OR (raw_laptop_allocation + over_order_reclaimed_laptops + circumstances_laptops) = raw_laptops_ordered)") }
  scope :has_fully_ordered_routers, -> { where("raw_routers_ordered > 0 AND (order_state = 'cannot_order' OR (raw_router_allocation + over_order_reclaimed_routers + circumstances_routers) = raw_routers_ordered)") }
  scope :has_partially_ordered_laptops, -> { where.not(order_state: :cannot_order).where('raw_laptops_ordered > 0 AND (raw_laptop_allocation + over_order_reclaimed_laptops + circumstances_laptops) > raw_laptops_ordered') }
  scope :has_partially_ordered_routers, -> { where.not(order_state: :cannot_order).where('raw_routers_ordered > 0 AND (raw_router_allocation + over_order_reclaimed_routers + circumstances_routers) > raw_routers_ordered') }
  scope :has_not_ordered_laptops, -> { where(raw_laptops_ordered: 0) }
  scope :has_not_ordered_routers, -> { where(raw_routers_ordered: 0) }
  scope :has_not_fully_ordered_laptops, -> { where.not(order_state: :cannot_order).where('(raw_laptop_allocation + over_order_reclaimed_laptops + circumstances_laptops) > raw_laptops_ordered') }
  scope :has_not_fully_ordered_routers, -> { where.not(order_state: :cannot_order).where('(raw_router_allocation + over_order_reclaimed_routers + circumstances_routers) > raw_routers_ordered') }

  scope :la_funded_provision, -> { where(type: 'LaFundedPlace') }
  scope :in_virtual_cap_pool, -> { where(in_virtual_cap_pool: true) }
  scope :iss_provision, -> { where(type: 'LaFundedPlace', provision_type: 'iss') }
  scope :scl_provision, -> { where(type: 'LaFundedPlace', provision_type: 'scl') }
  scope :that_can_order_now, -> { where(order_state: %w[can_order_for_specific_circumstances can_order]) }
  scope :where_urn_or_ukprn, ->(identifier) { where('urn = ? OR ukprn = ?', identifier, identifier) }
  scope :where_urn_or_ukprn_or_provision_urn, ->(identifier) { where('urn = ? OR ukprn = ? OR provision_urn = ?', identifier.to_i, identifier.to_i, identifier.to_s) }
  scope :with_over_order_stolen_cap, lambda { |device_type|
    laptop?(device_type) ? where('over_order_reclaimed_laptops < 0') : where('over_order_reclaimed_routers < 0')
  }
  scope :school_not_set_to_order_devices, -> { where(who_will_order_devices: [nil, :responsible_body]) }

  def self.laptop?(device_type)
    device_type.to_sym == :laptop
  end

  def self.that_can_order_now
    where(order_state: %w[can_order_for_specific_circumstances can_order])
  end

  def self.requiring_a_new_computacenter_reference
    gias_status_open.where(computacenter_change: %w[new amended]).or(gias_status_open.where(computacenter_reference: nil))
  end

  def self.with_available_cap(device_type)
    if laptop?(device_type)
      where('(raw_laptop_allocation + over_order_reclaimed_laptops + circumstances_laptops) > raw_laptops_ordered')
        .where.not(order_state: :cannot_order)
        .order(Arel.sql('(raw_laptop_allocation + over_order_reclaimed_laptops + circumstances_laptops) - raw_laptops_ordered'))
    else
      where('(raw_router_allocation + over_order_reclaimed_routers + circumstances_routers) > raw_routers_ordered')
        .where.not(order_state: :cannot_order)
        .order(Arel.sql('(raw_router_allocation + over_order_reclaimed_routers + circumstances_routers) - raw_routers_ordered'))
    end
  end

  def initialize(*args)
    super
    self.preorder_status ||= infer_status
  end

  delegate :laptop?, to: :class

  delegate :allocation, to: :responsible_body, prefix: :vcap, private: true
  delegate :cap, to: :responsible_body, prefix: :vcap, private: true
  delegate :devices_ordered, to: :responsible_body, prefix: :vcap, private: true

  delegate :email_address, to: :headteacher, allow_nil: true, prefix: true
  delegate :id, to: :headteacher, allow_nil: true, prefix: true
  delegate :full_name, to: :headteacher, allow_nil: true, prefix: true
  delegate :phone_number, to: :headteacher, allow_nil: true, prefix: true
  delegate :title, to: :headteacher, allow_nil: true, prefix: true

  delegate :calculate_vcap, to: :responsible_body, prefix: false
  delegate :companies_house_number, to: :responsible_body, prefix: true, allow_nil: true
  delegate :computacenter_reference, to: :responsible_body, prefix: true, allow_nil: true
  delegate :gias_id, to: :responsible_body, prefix: true, allow_nil: true
  delegate :name, to: :responsible_body, prefix: true, allow_nil: true

  def active_responsible_users
    device_ordering_organisation.users.signed_in_at_least_once
  end

  def address
    address_components.join(', ')
  end

  def address_components
    [address_1, address_2, address_3, town, county, postcode].reject(&:blank?)
  end

  def allocation(device_type)
    in_virtual_cap_pool? ? vcap_allocation(device_type) : raw_allocation(device_type)
  end

  def all_devices_ordered?
    eligible_to_order? && !devices_available_to_order?
  end

  def available_mobile_networks
    hide_networks_not_supporting_fe? ? MobileNetwork.fe_networks : MobileNetwork.participating
  end

  def can_change_who_manages_orders?
    !(orders_managed_centrally? && responsible_body.vcap_feature_flag?)
  end

  def can_invite_users?
    !orders_managed_centrally?
  end

  def cap(device_type)
    in_virtual_cap_pool? ? vcap_cap(device_type) : raw_cap(device_type)
  end

  def circumstances_devices(device_type)
    laptop?(device_type) ? circumstances_laptops : circumstances_routers
  end

  def circumstances_devices_field(device_type)
    laptop?(device_type) ? :circumstances_laptops : :circumstances_routers
  end

  def computacenter_cap(device_type)
    return cap(device_type) unless in_virtual_cap_pool?

    vcap_cap(device_type) - vcap_devices_ordered(device_type) + raw_devices_ordered(device_type)
  end

  def computacenter_references?
    [computacenter_reference, responsible_body_computacenter_reference].all?(&:present?)
  end

  def can_order_devices_right_now?
    eligible_to_order? && devices_available_to_order?
  end

  def can_order_routers_only_right_now?
    eligible_to_order? && !devices_available_to_order?(:laptop) && devices_available_to_order?(:router)
  end

  def chromebook_domain
    school_or_rb_domain if will_need_chromebooks?
  end

  def chromebook_information_complete?
    return true if la_funded_provision?
    return will_not_need_chromebooks? unless will_need_chromebooks?

    [school_or_rb_domain, recovery_email_address].all?(&:present?)
  end

  def chromebook_info_still_needed?
    will_need_chromebooks.nil? || will_need_chromebooks == 'i_dont_know'
  end

  def close!
    update!(status: 'closed', computacenter_change: 'closed') unless gias_status_closed?
  end

  def completed_requests_count
    if in_virtual_cap_pool?
      responsible_body.extra_mobile_data_requests.complete_status.size
    else
      extra_mobile_data_requests.complete_status.size
    end
  end

  def devices_available_to_order(device_type)
    [0, cap(device_type) - devices_ordered(device_type)].max
  end

  def devices_available_to_order?(device_type = nil)
    return devices_available_to_order(device_type).positive? if device_type

    devices_available_to_order?(:laptop) || devices_available_to_order?(:router)
  end

  def devices_ordered(device_type)
    in_virtual_cap_pool? ? vcap_devices_ordered(device_type) : raw_devices_ordered(device_type)
  end

  def eligible_to_order?
    can_order? || can_order_for_specific_circumstances?
  end

  def further_education?
    type == 'FurtherEducationSchool'
  end

  def has_not_fully_ordered_laptops_now?
    raw_cap(:laptop) > raw_devices_ordered(:laptop)
  end

  def has_ordered?
    has_ordered_any_laptop? || has_ordered_any_router?
  end

  def has_ordered_any_laptop?
    devices_ordered(:laptop).positive?
  end

  def has_ordered_any_router?
    devices_ordered(:router).positive?
  end

  def headteacher?
    headteacher.present?
  end

  def invite_school_contact
    if school_contact
      transaction do
        user = CreateUserService.invite_school_user(email_address: school_contact.email_address,
                                                    full_name: school_contact.full_name,
                                                    telephone: school_contact.phone_number,
                                                    school_id: id,
                                                    orders_devices: true)
        reload.update!(school_contacted_at: Time.zone.now, preorder_status: infer_status) if user.errors.blank?
      end
    end
  end

  def in_virtual_cap_pool?
    responsible_body.vcap_feature_flag? && !la_funded_provision? && orders_managed_centrally?
  end

  def independent_special_school?
    provision_type == 'iss'
  end

  def has_allocation?(device_type)
    allocation(device_type).positive?
  end

  def la_funded_provision?
    type == 'LaFundedPlace'
  end

  def laptops
    [allocation(:laptop), cap(:laptop), devices_ordered(:laptop)]
  end

  def laptops_full
    [
      allocation(:laptop),
      circumstances_devices(:laptop),
      over_order_reclaimed_devices(:laptop),
      devices_ordered(:laptop),
    ]
  end

  def next_school_in_responsible_body_when_sorted_by_name_ascending
    responsible_body.next_school_sorted_ascending_by_name(self)
  end

  def opt_in!
    update!(opted_out_of_comms_at: nil)
  end

  def opt_out!
    update!(opted_out_of_comms_at: Time.zone.now)
  end

  def opted_out?
    !!opted_out_of_comms_at
  end

  def orders_managed_centrally?
    return false if school_will_order_devices?

    responsible_body_will_order_devices? || responsible_body.responsible_body_will_order_devices_for_schools_by_default?
  end

  def orders_managed_by_school?
    return false if responsible_body_will_order_devices?

    school_will_order_devices? || responsible_body&.schools_will_order_devices_by_default?
  end

  def orders_managed_by!(who, clear_preorder_information: false)
    clear_preorder_information! if clear_preorder_information
    who.to_sym == :school ? school_will_order_devices! : responsible_body_will_order_devices!
  end

  def order_users_with_active_techsource_accounts
    device_ordering_organisation
      .users
      .who_can_order_devices
      .with_techsource_account_confirmed
  end

  def organisation_users
    device_ordering_organisation.users
  end

  def over_order_reclaimed_devices(device_type)
    laptop?(device_type) ? over_order_reclaimed_laptops : over_order_reclaimed_routers
  end

  def over_order_reclaimed_devices_field(device_type)
    laptop?(device_type) ? :over_order_reclaimed_laptops : :over_order_reclaimed_routers
  end

  def raw_allocation(device_type)
    laptop?(device_type) ? raw_laptop_allocation : raw_router_allocation
  end

  def raw_allocation_field(device_type)
    laptop?(device_type) ? :raw_laptop_allocation : :raw_router_allocation
  end

  def raw_cap(device_type)
    return raw_devices_ordered(device_type) if cannot_order?

    raw_allocation(device_type) + over_order_reclaimed_devices(device_type) + circumstances_devices(device_type)
  end

  def raw_devices_available_to_order(device_type)
    [0, raw_cap(device_type) - raw_devices_ordered(device_type)].max
  end

  def raw_devices_ordered(device_type)
    laptop?(device_type) ? raw_laptops_ordered : raw_routers_ordered
  end

  def raw_devices_ordered_field(device_type)
    laptop?(device_type) ? :raw_laptops_ordered : :raw_routers_ordered
  end

  def raw_laptops
    [raw_allocation(:laptop), raw_cap(:laptop), raw_devices_ordered(:laptop)]
  end

  def raw_laptops_full
    [
      raw_allocation(:laptop),
      circumstances_devices(:laptop),
      over_order_reclaimed_devices(:laptop),
      raw_devices_ordered(:laptop),
    ]
  end

  def raw_routers
    [raw_allocation(:router), raw_cap(:router), raw_devices_ordered(:router)]
  end

  def raw_routers_full
    [
      raw_allocation(:router),
      circumstances_devices(:router),
      over_order_reclaimed_devices(:router),
      raw_devices_ordered(:router),
    ]
  end

  def routers
    [allocation(:router), cap(:router), devices_ordered(:router)]
  end

  def routers_full
    [
      allocation(:router),
      circumstances_devices(:router),
      over_order_reclaimed_devices(:router),
      devices_ordered(:router),
    ]
  end

  def refresh_preorder_status!
    update!(preorder_status: infer_status)
  end

  def school_contact=(value)
    super(value)
    self.preorder_status = infer_status
  end

  def set_contact_time!(time)
    update!(school_contacted_at: time)
  end

  def set_school_contact!(contact)
    update!(school_contact: contact)
  end

  def set_headteacher_as_contact!
    update!(school_contact: headteacher)
  end

  def social_care_leaver?
    provision_type == 'scl'
  end

  def timestamp_cap_update!(device_type, timestamp, payload_id)
    timestamp_field = "#{device_type}_cap_update_request_timestamp"
    payload_field = "#{device_type}_cap_update_request_payload_id"
    update!(timestamp_field => timestamp, payload_field => payload_id)
  end

  def update_chromebook_information_and_status!(params)
    update!(params)
    refresh_preorder_status!
  end

  def will_need_chromebooks?
    will_need_chromebooks == 'yes'
  end

  def will_not_need_chromebooks?
    will_need_chromebooks == 'no'
  end

  def who_manages_orders_label
    return 'School or college' if orders_managed_by_school?

    responsible_body_type if orders_managed_centrally?
  end

private

  def any_school_users?
    user_schools.exists?
  end

  def check_and_update_status_if_necessary
    self.preorder_status = infer_status if will_need_chromebooks_changed? || who_will_order_devices_changed?
  end

  def clear_preorder_information!
    update!(school_contacted_at: nil,
            recovery_email_address: nil,
            school_or_rb_domain: nil,
            will_need_chromebooks: nil,
            school_contact_id: nil)
    refresh_preorder_status!
  end

  def device_ordering_organisation
    orders_managed_by_school? ? self : responsible_body
  end

  def hide_networks_not_supporting_fe?
    hide_mno?
  end

  def infer_status
    if orders_managed_by_school?
      if any_school_users?
        return 'school_contacted' unless chromebook_information_complete?
        return 'school_can_order' if can_order_devices_right_now?

        return has_ordered? ? 'ordered' : 'school_ready'
      end
      return school_contact.present? ? 'school_will_be_contacted' : 'needs_contact'
    end
    return 'needs_info' unless chromebook_information_complete?
    return 'ready' unless responsible_body_will_order_devices?
    return 'rb_can_order' if can_order_devices_right_now?

    has_ordered? ? 'ordered' : 'ready'
  end

  def maybe_generate_user_changes
    user_schools.map(&:user).each(&:generate_user_change_if_needed!)
  end

  def responsible_body_type
    responsible_body.humanized_type.capitalize
  end

  def set_computacenter_change
    self.computacenter_change = 'new'
  end
end
