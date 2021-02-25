class School < ApplicationRecord
  has_paper_trail
  include PgSearch::Model
  include SchoolType

  belongs_to :responsible_body

  has_many   :device_allocations, class_name: 'SchoolDeviceAllocation'
  has_one    :std_device_allocation, -> { where device_type: 'std_device' }, class_name: 'SchoolDeviceAllocation'
  has_one    :coms_device_allocation, -> { where device_type: 'coms_device' }, class_name: 'SchoolDeviceAllocation'

  has_many :contacts, class_name: 'SchoolContact', inverse_of: :school
  has_many :user_schools
  has_many :users, through: :user_schools
  has_one :preorder_information, touch: true
  has_many :email_audits
  has_many :extra_mobile_data_requests
  has_many :school_links, dependent: :destroy
  has_many :devices_ordered_updates, class_name: 'Computacenter::DevicesOrderedUpdate',
                                     primary_key: :computacenter_reference,
                                     foreign_key: :ship_to

  validates :name, presence: true

  pg_search_scope :matching_name_or_urn_or_ukprn, against: %i[name urn ukprn], using: { tsearch: { prefix: true } }

  before_create :set_computacenter_change

  enum status: {
    open: 'open',
    closed: 'closed',
  }, _prefix: 'gias_status'

  enum order_state: {
    cannot_order: 'cannot_order',
    cannot_order_as_reopened: 'cannot_order_as_reopened',
    can_order_for_specific_circumstances: 'can_order_for_specific_circumstances',
    can_order: 'can_order',
  }

  enum computacenter_change: {
    none: 'none',
    new: 'new',
    amended: 'amended',
    closed: 'closed',
  }, _prefix: true

  scope :where_urn_or_ukprn, ->(identifier) { where('urn = ? OR ukprn = ?', identifier, identifier) }
  scope :further_education, -> { where(type: 'FurtherEducationSchool') }

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

  def ukprn_or_urn
    ukprn || urn
  end

  def is_further_education?
    type == 'FurtherEducationSchool'
  end

  def has_ordered?
    device_allocations.to_a.any? { |alloc| alloc.devices_ordered.positive? }
  end

  def who_will_order_devices
    preorder_information&.who_will_order_devices || responsible_body.who_will_order_devices
  end

  def active_responsible_users
    device_ordering_organisation.users.signed_in_at_least_once
  end

  def order_users_with_active_techsource_accounts
    device_ordering_organisation
      .users
      .who_can_order_devices
      .with_techsource_account_confirmed
  end

  def organisation_users
    device_ordering_organisation
      .users
  end

  def allocation_for_type!(device_type)
    device_allocations.find_by_device_type!(device_type)
  end

  def can_order_devices_right_now?
    is_eligible_to_order? && has_devices_available_to_order?
  end

  def can_order_routers_only_right_now?
    is_eligible_to_order? && !std_device_allocation&.has_devices_available_to_order? && coms_device_allocation&.has_devices_available_to_order?
  end

  def all_devices_ordered?
    is_eligible_to_order? && !has_devices_available_to_order?
  end

  def has_std_device_allocation?
    std_device_allocation&.allocation.to_i.positive?
  end

  def headteacher_contact
    contacts.find_by(role: :headteacher)
  end

  def current_contact
    preorder_information&.school_contact
  end

  # TODO: update this method as preorder_information gets more fields
  # as per the prototype at
  # https://github.com/DFE-Digital/increasing-internet-access-prototype/blob/master/app/views/responsible-body/devices/school/_status-tag.html
  def preorder_status_or_default
    if preorder_information.present?
      preorder_information.status || preorder_information.infer_status
    elsif responsible_body.who_will_order_devices == 'responsible_body'
      'needs_info'
    else
      'needs_contact'
    end
  end

  def next_school_in_responsible_body_when_sorted_by_name_ascending
    responsible_body.next_school_sorted_ascending_by_name(self)
  end

  def invite_school_contact
    if preorder_information.present?
      preorder_information.invite_school_contact!
    else
      false
    end
  end

  def has_devices_available_to_order?
    device_allocations.any?(&:has_devices_available_to_order?)
  end

  def in_virtual_cap_pool?
    responsible_body.has_school_in_virtual_cap_pools?(self)
  end

  def address_components
    [address_1, address_2, address_3, town, county, postcode].reject(&:blank?)
  end

  def address
    address_components.join(', ')
  end

  def update_computacenter_reference!(new_value)
    update!(computacenter_reference: new_value, computacenter_change: 'none')
  end

  def chromebook_domain
    preorder_information&.school_or_rb_domain if preorder_information&.will_need_chromebooks?
  end

  def show_mno?
    !hide_mno?
  end

  def can_invite_users?
    return true if preorder_information.nil?

    preorder_information.school_will_order_devices?
  end

  def close!
    update!(status: 'closed', computacenter_change: 'closed') unless gias_status_closed?
  end

private

  def maybe_generate_user_changes
    user_schools.map(&:user).each(&:generate_user_change_if_needed!)
  end

  def set_computacenter_change
    self.computacenter_change = 'new'
  end

  def device_ordering_organisation
    who_will_order_devices == 'school' ? self : responsible_body
  end

  def is_eligible_to_order?
    can_order? || can_order_for_specific_circumstances?
  end
end
