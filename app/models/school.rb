class School < ApplicationRecord
  has_paper_trail
  include PgSearch::Model
  include SchoolType

  belongs_to :responsible_body

  has_many :device_allocations, class_name: 'SchoolDeviceAllocation', inverse_of: :school
  has_one :std_device_allocation, -> { where device_type: 'std_device' }, class_name: 'SchoolDeviceAllocation', inverse_of: :school
  has_one :coms_device_allocation, -> { where device_type: 'coms_device' }, class_name: 'SchoolDeviceAllocation', inverse_of: :school

  has_many :contacts, class_name: 'SchoolContact', inverse_of: :school
  has_one :headteacher, -> { where role: 'headteacher' }, class_name: 'SchoolContact', inverse_of: :school
  has_many :user_schools
  has_many :users, through: :user_schools
  has_one :preorder_information, touch: true
  has_many :email_audits
  has_many :extra_mobile_data_requests
  has_many :school_links, dependent: :destroy
  has_many :devices_ordered_updates, class_name: 'Computacenter::DevicesOrderedUpdate',
                                     primary_key: :computacenter_reference,
                                     foreign_key: :ship_to
  has_many :std_device_allocation_changes, through: :std_device_allocation, source: :allocation_change

  validates :name, presence: true

  pg_search_scope :matching_name_or_urn_or_ukprn_or_provision_urn, against: %i[name urn ukprn provision_urn], using: { tsearch: { prefix: true } }

  before_create :set_computacenter_change

  enum computacenter_change: {
    none: 'none',
    new: 'new',
    amended: 'amended',
    closed: 'closed',
  }, _prefix: true

  enum status: {
    open: 'open',
    closed: 'closed',
  }, _prefix: 'gias_status'

  enum order_state: {
    cannot_order: 'cannot_order',
    can_order_for_specific_circumstances: 'can_order_for_specific_circumstances',
    can_order: 'can_order',
  }

  scope :where_urn_or_ukprn, ->(identifier) { where('urn = ? OR ukprn = ?', identifier, identifier) }
  scope :where_urn_or_ukprn_or_provision_urn, ->(identifier) { where('urn = ? OR ukprn = ? OR provision_urn = ?', identifier.to_i, identifier.to_i, identifier.to_s) }
  scope :further_education, -> { where(type: 'FurtherEducationSchool') }
  scope :la_funded_provision, -> { where(type: 'LaFundedPlace') }
  scope :iss_provision, -> { where(type: 'LaFundedPlace', provision_type: 'iss') }
  scope :scl_provision, -> { where(type: 'LaFundedPlace', provision_type: 'scl') }
  scope :excluding_la_funded_provisions, -> { where.not(type: 'LaFundedPlace') }

  after_update :maybe_generate_user_changes

  def self.that_will_order_devices
    joins(:preorder_information).merge(PreorderInformation.school_will_order_devices)
  end

  def self.that_are_centrally_managed
    joins(:preorder_information).merge(PreorderInformation.responsible_body_will_order_devices)
  end

  def self.that_can_order_now
    where(order_state: %w[can_order_for_specific_circumstances can_order])
  end

  def self.requiring_a_new_computacenter_reference
    gias_status_open.where(computacenter_change: %w[new amended]).or(gias_status_open.where(computacenter_reference: nil))
  end

  delegate :email_address, to: :headteacher, allow_nil: true, prefix: true
  delegate :id, to: :headteacher, allow_nil: true, prefix: true
  delegate :full_name, to: :headteacher, allow_nil: true, prefix: true
  delegate :phone_number, to: :headteacher, allow_nil: true, prefix: true
  delegate :title, to: :headteacher, allow_nil: true, prefix: true

  delegate :chromebook_information_complete?, to: :preorder_information
  delegate :needs_contact?, :needs_contact!, to: :preorder_information, allow_nil: true
  delegate :needs_info?, :needs_info!, to: :preorder_information, allow_nil: true
  delegate :ordered?, :ordered!, to: :preorder_information, allow_nil: true
  delegate :ready?, :ready!, to: :preorder_information, allow_nil: true
  delegate :rb_can_order?, :rb_can_order!, to: :preorder_information, allow_nil: true
  delegate :school_can_order?, :school_can_order!, to: :preorder_information, allow_nil: true
  delegate :school_contacted?, :school_contacted!, to: :preorder_information, allow_nil: true
  delegate :school_ready?, :school_ready!, to: :preorder_information, allow_nil: true
  delegate :school_will_be_contacted?, :school_will_be_contacted!, to: :preorder_information, allow_nil: true
  delegate :recovery_email_address, to: :preorder_information, allow_nil: true
  delegate :responsible_body_will_order_devices?, to: :preorder_information, allow_nil: true, private: true
  delegate :status, to: :preorder_information, allow_nil: true, prefix: :device_ordering
  delegate :school_or_rb_domain, to: :preorder_information, allow_nil: true
  delegate :school_will_order_devices?, to: :preorder_information, allow_nil: true, private: true
  delegate :update_chromebook_information_and_status!, to: :preorder_information
  delegate :will_need_chromebooks, to: :preorder_information, allow_nil: true
  delegate :will_need_chromebooks?, to: :preorder_information, allow_nil: true
  delegate :will_not_need_chromebooks?, to: :preorder_information, allow_nil: true

  delegate :cap_implied_by_order_state, to: :std_device_allocation, allow_nil: true, prefix: :laptop
  delegate :computacenter_cap, to: :std_device_allocation, prefix: :laptop, allow_nil: true
  delegate :allocation=, to: :std_device_allocation, prefix: :laptop

  delegate :cap_implied_by_order_state, to: :coms_device_allocation, allow_nil: true, prefix: :router
  delegate :computacenter_cap, to: :coms_device_allocation, prefix: :router, allow_nil: true
  delegate :allocation=, to: :coms_device_allocation, prefix: :router

  delegate :computacenter_reference, to: :responsible_body, prefix: true, allow_nil: true
  delegate :name, to: :responsible_body, prefix: true, allow_nil: true

  def active_responsible_users
    device_ordering_organisation.users.signed_in_at_least_once
  end

  def addable_to_virtual_cap_pool?
    !la_funded_provision? && orders_managed_centrally? && any_allocation_id?
  end

  def address
    address_components.join(', ')
  end

  def address_components
    [address_1, address_2, address_3, town, county, postcode].reject(&:blank?)
  end

  def adjusted_laptop_cap_by_order_state(cap, state: order_state)
    return raw_laptops_ordered if state == 'cannot_order'

    state == 'can_order' ? raw_laptop_allocation : cap
  end

  def adjusted_router_cap_by_order_state(cap, state: order_state)
    return raw_routers_ordered if state == 'cannot_order'

    state == 'can_order' ? raw_router_allocation : cap
  end

  def allocation_ids
    [laptop_allocation_id, router_allocation_id].compact
  end

  def all_devices_ordered?
    eligible_to_order? && !devices_available_to_order?
  end

  def any_allocation_id?
    (laptop_allocation_id || router_allocation_id).present?
  end

  def available_mobile_networks
    hide_networks_not_supporting_fe? ? MobileNetwork.fe_networks : MobileNetwork.participating
  end

  def can_change_who_manages_orders?
    !(responsible_body_will_order_devices? && responsible_body.has_virtual_cap_feature_flags?)
  end

  def can_invite_users?
    !preorder_information? || school_will_order_devices?
  end

  def computacenter_references?
    [computacenter_reference, responsible_body_computacenter_reference].all?(&:present?)
  end

  def can_order_devices_right_now?
    eligible_to_order? && devices_available_to_order?
  end

  def can_order_routers_only_right_now?
    eligible_to_order? && !laptops_available_to_order? && routers_available_to_order?
  end

  def change_who_manages_orders!(who, clear_preorder_information: false)
    if can_change_who_manages_orders?
      orders_managed_by!(who, clear_preorder_information: clear_preorder_information)
      refresh_device_ordering_status!
      AddSchoolToVirtualCapPoolService.new(self).call
      true
    else
      raise VirtualCapPoolError, "#{name} (#{urn}) cannot be devolved because it is in a virtual cap pool"
    end
  end

  def chromebook_domain
    preorder_information&.school_or_rb_domain if will_need_chromebooks?
  end

  def chromebook_info_still_needed?
    !preorder_information? || preorder_information.chromebook_info_still_needed?
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

  def current_contact
    preorder_information&.school_contact
  end

  def devices_available_to_order?
    laptops_available_to_order? || routers_available_to_order?
  end

  def eligible_to_order?
    can_order? || can_order_for_specific_circumstances?
  end

  def further_education?
    type == 'FurtherEducationSchool'
  end

  def has_ordered?
    has_ordered_any_laptop? || has_ordered_any_router?
  end

  def has_ordered_any_laptop?
    laptops_ordered.positive?
  end

  def has_ordered_any_router?
    routers_ordered.positive?
  end

  def headteacher?
    headteacher.present?
  end

  def invite_school_contact
    !!preorder_information&.invite_school_contact!
  end

  def in_active_virtual_cap_pool?
    responsible_body.has_virtual_cap_feature_flags? && in_virtual_cap_pool?
  end

  def independent_special_school?
    provision_type == 'iss'
  end

  def in_virtual_cap_pool?(**opts)
    std_device_allocation&.in_virtual_cap_pool?(**opts) || coms_device_allocation&.in_virtual_cap_pool?(**opts)
  end

  def has_laptop_allocation?
    laptop_allocation.positive?
  end

  def laptop_allocation
    std_device_allocation&.allocation.to_i
  end

  def laptop_allocation_id
    std_device_allocation&.id
  end

  def laptop_cap
    std_device_allocation&.cap.to_i
  end

  def laptops_available_to_order?
    std_device_allocation&.devices_available_to_order?
  end

  def laptops_available_to_order
    std_device_allocation&.devices_available_to_order.to_i
  end

  def laptops_ordered
    std_device_allocation&.devices_ordered.to_i
  end

  def la_funded_provision?
    type == 'LaFundedPlace'
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

  def orders_managed_centrally!
    change_who_manages_orders!(:responsible_body)
  end

  def orders_managed_centrally?
    return false if school_will_order_devices?

    responsible_body_will_order_devices? || responsible_body.orders_managed_centrally?
  end

  def orders_managed_by_school!
    change_who_manages_orders!(:school)
  end

  def orders_managed_by_school?
    return false if responsible_body_will_order_devices?

    school_will_order_devices? || responsible_body.orders_managed_by_schools?
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

  def preorder_information?
    preorder_information.present?
  end

  # TODO: update this method as preorder_information gets more fields
  # as per the prototype at
  # https://github.com/DFE-Digital/increasing-internet-access-prototype/blob/master/app/views/responsible-body/devices/school/_status-tag.html
  def preorder_status_or_default
    if preorder_information?
      preorder_information.status || preorder_information.infer_status
    elsif responsible_body.orders_managed_centrally?
      'needs_info'
    else
      'needs_contact'
    end
  end

  def raw_laptop_allocation
    std_device_allocation&.raw_allocation.to_i
  end

  def raw_laptop_cap
    std_device_allocation&.raw_cap.to_i
  end

  def raw_laptops_ordered
    std_device_allocation&.raw_devices_ordered.to_i
  end

  def raw_router_allocation
    coms_device_allocation&.raw_allocation.to_i
  end

  def raw_router_cap
    coms_device_allocation&.raw_cap.to_i
  end

  def raw_routers_ordered
    coms_device_allocation&.raw_devices_ordered.to_i
  end

  def refresh_device_ordering_status!
    preorder_information&.refresh_status!
  end

  def router_allocation
    coms_device_allocation&.allocation.to_i
  end

  def router_allocation_id
    coms_device_allocation&.id
  end

  def router_cap
    coms_device_allocation&.cap.to_i
  end

  def routers_available_to_order?
    coms_device_allocation&.devices_available_to_order?
  end

  def routers_available_to_order
    coms_device_allocation&.devices_available_to_order.to_i
  end

  def routers_ordered
    coms_device_allocation&.devices_ordered.to_i
  end

  def set_contact_time!(time)
    preorder_information.update!(school_contacted_at: time)
  end

  def set_current_contact!(contact)
    preorder_information.update!(school_contact: contact)
  end

  def set_headteacher_as_contact!
    preorder_information.update!(school_contact: headteacher)
  end

  def set_laptop_ordering!(**opts)
    find_or_build_std_device_allocation.tap do |record|
      record.allocation = opts[:allocation] || raw_laptop_allocation
      record.cap = adjusted_laptop_cap_by_order_state(opts[:cap] || raw_laptop_cap)
      record.save!
    end
    reload.refresh_device_ordering_status!
  end

  def set_router_ordering!(**opts)
    find_or_build_coms_device_allocation.tap do |record|
      record.allocation = opts[:allocation] || raw_router_allocation
      record.cap = adjusted_router_cap_by_order_state(opts[:cap] || raw_router_cap)
      record.save!
    end
    reload.refresh_device_ordering_status!
  end

  def social_care_leaver?
    provision_type == 'scl'
  end

  def who_will_order_devices
    preorder_information&.who_will_order_devices || responsible_body.who_will_order_devices
  end

  def who_manages_orders_label
    return 'School or college' if orders_managed_by_school?

    responsible_body_type if orders_managed_centrally?
  end

private

  def clear_preorder_information!
    preorder_information&.destroy!
    self.preorder_information = nil
  end

  def device_ordering_organisation
    orders_managed_by_school? ? self : responsible_body
  end

  def find_or_build_preorder_information
    (preorder_information || build_preorder_information)
  end

  def find_or_build_std_device_allocation
    (std_device_allocation || build_std_device_allocation)
  end

  def find_or_build_coms_device_allocation
    (coms_device_allocation || build_coms_device_allocation)
  end

  def hide_networks_not_supporting_fe?
    hide_mno?
  end

  def maybe_generate_user_changes
    user_schools.map(&:user).each(&:generate_user_change_if_needed!)
  end

  def orders_managed_by!(who, clear_preorder_information: false)
    clear_preorder_information! if clear_preorder_information
    manager = who.to_sym == :school ? :school_will_order_devices! : :responsible_body_will_order_devices!
    find_or_build_preorder_information.send(manager)
  end

  def responsible_body_type
    responsible_body.humanized_type.capitalize
  end

  def set_computacenter_change
    self.computacenter_change = 'new'
  end
end
