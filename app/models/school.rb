class School < ApplicationRecord
  has_paper_trail

  belongs_to :responsible_body
  has_many   :device_allocations, class_name: 'SchoolDeviceAllocation'
  has_one    :std_device_allocation, -> { where device_type: 'std_device' }, class_name: 'SchoolDeviceAllocation'
  has_one    :coms_device_allocation, -> { where device_type: 'coms_device' }, class_name: 'SchoolDeviceAllocation'

  has_many :contacts, class_name: 'SchoolContact', inverse_of: :school
  has_many :user_schools
  has_many :users, through: :user_schools
  has_one :preorder_information
  has_many :email_audits
  has_many :extra_mobile_data_requests
  has_many :devices_ordered_updates, class_name: 'Computacenter::DevicesOrderedUpdate',
                                     primary_key: :computacenter_reference,
                                     foreign_key: :ship_to

  validates :urn, presence: true, format: { with: /\A\d{6}\z/ }
  validates :name, presence: true

  before_create :set_computacenter_change

  enum status: {
    open: 'open',
    closed: 'closed',
  }, _prefix: 'gias_status'

  enum phase: {
    primary: 'primary',
    secondary: 'secondary',
    all_through: 'all_through',
    sixteen_plus: 'sixteen_plus',
    nursery: 'nursery',
    phase_not_applicable: 'phase_not_applicable',
  }

  enum establishment_type: {
    academy: 'academy',
    free: 'free',
    local_authority: 'local_authority',
    special: 'special',
    other_type: 'other_type',
  }, _suffix: true

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

  def all_devices_ordered?
    is_eligible_to_order? && !has_devices_available_to_order?
  end

  def has_std_device_allocation?
    std_device_allocation&.allocation.to_i.positive?
  end

  def type_label
    if special_establishment_type?
      'Special school'
    elsif !phase_not_applicable?
      "#{phase.humanize.upcase_first} school"
    else
      ''
    end
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

  def to_param
    urn.to_s
  end

  def has_devices_available_to_order?
    device_allocations.any?(&:has_devices_available_to_order?)
  end

  def in_virtual_cap_pool?
    responsible_body.has_school_in_virtual_cap_pools?(self)
  end

  def address
    [address_1, address_2, address_3, town, postcode].reject(&:blank?).join(', ')
  end

private

  def maybe_generate_user_changes
    users.each(&:generate_user_change_if_needed!)
  end

  def set_computacenter_change
    self.computacenter_change = 'new' unless computacenter_change
  end

  def device_ordering_organisation
    who_will_order_devices == 'school' ? self : responsible_body
  end

  def is_eligible_to_order?
    can_order? || can_order_for_specific_circumstances?
  end
end
