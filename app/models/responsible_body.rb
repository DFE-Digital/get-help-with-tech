require 'computacenter/responsible_body_urns'

class ResponsibleBody < ApplicationRecord
  has_one :bt_wifi_voucher_allocation
  belongs_to :key_contact, class_name: 'User', optional: true
  has_many :bt_wifi_vouchers
  has_many :users
  has_many :extra_mobile_data_requests
  has_many :schools

  has_many :donated_device_requests, dependent: :destroy

  scope :excluding_department_for_education, -> { where.not(type: 'DfE') }

  extend Computacenter::ResponsibleBodyUrns::ClassMethods
  include Computacenter::ResponsibleBodyUrns::InstanceMethods

  before_create :set_computacenter_change

  enum status: {
    open: 'open',
    closed: 'closed',
  }, _prefix: 'gias_status'

  enum computacenter_change: {
    none: 'none',
    new: 'new',
    amended: 'amended',
    closed: 'closed',
  }, _prefix: true

  after_update :maybe_generate_user_changes

  def self.chosen_who_will_order
    where.not(who_will_order_devices: nil)
  end

  def self.managing_multiple_chromebook_domains
    where(
      <<~SQL,
        id IN
          (SELECT rb_id FROM
            (SELECT DISTINCT s.responsible_body_id AS rb_id, s.school_or_rb_domain
              FROM schools s
              WHERE s.status = 'open'
              AND s.who_will_order_devices='responsible_body'
              AND NOT (s.school_or_rb_domain = '' OR s.school_or_rb_domain IS NULL)
              AND s.type <> 'LaFundedPlace'
            ) AS t1
            GROUP BY t1.rb_id HAVING COUNT(*) > 1
          )
      SQL
    )
  end

  def self.with_at_least_one_preorder_information_completed
    where(
      "EXISTS(
        SELECT  schools.id
        FROM    schools
        WHERE   schools.responsible_body_id = responsible_bodies.id
          AND   schools.type <> 'LaFundedPlace'
          AND   schools.preorder_status NOT IN (?)
      )", %w[needs_info needs_contact]
    )
  end

  def self.with_completed_preorder_info_count
    select(
      "
        (SELECT COUNT(*)
          FROM  schools
          WHERE schools.responsible_body_id = responsible_bodies.id
            AND schools.type <> 'LaFundedPlace'
            AND schools.preorder_status NOT IN ('needs_info', 'needs_contact')
        ) AS completed_preorder_info_count
      ",
    )
  end

  def self.with_users_who_have_signed_in_at_least_once(privacy_notice_required: false)
    sql = <<~SQL
      (
        SELECT COUNT(*)
        FROM  users
        WHERE responsible_body_id=responsible_bodies.id
          AND sign_in_count > 0
          #{privacy_notice_required ? ' AND privacy_notice_seen_at IS NOT NULL' : ''}
      )
      AS  users_who_have_signed_in_at_least_once
    SQL
    select(sql)
  end

  def self.with_user_count(privacy_notice_required: false)
    sql = <<~SQL
      (
          SELECT  COUNT(*)
          FROM    users
          WHERE   responsible_body_id=responsible_bodies.id
            #{privacy_notice_required ? ' AND privacy_notice_seen_at IS NOT NULL' : ''}
      )
      AS user_count
    SQL
    select(sql)
  end

  def active_schools
    schools.gias_status_open.excluding_la_funded_provisions
  end

  def allocation(device_type)
    laptop?(device_type) ? laptop_allocation : router_allocation
  end

  def address
    [address_1, address_2, address_3, town, postcode].reject(&:blank?).join(', ')
  end

  def cap(device_type)
    laptop?(device_type) ? laptop_cap : router_cap
  end

  def devices_available_to_order?(device_type = nil)
    return devices_available_to_order(device_type).positive? if device_type

    devices_available_to_order?(:laptop) || devices_available_to_order?(:router)
  end

  def devices_available_to_order(device_type)
    [0, cap(device_type) - devices_ordered(device_type)].max
  end

  def devices_ordered(device_type)
    laptop?(device_type) ? laptops_ordered : routers_ordered
  end

  def further_education_college?
    type == 'FurtherEducationCollege'
  end

  def has_any_schools_that_can_order_now?
    active_schools.that_can_order_now.any?
  end

  def has_centrally_managed_schools?
    active_schools.responsible_body_will_order_devices.any?
  end

  def has_centrally_managed_schools_that_can_order_now?
    active_schools.responsible_body_will_order_devices.that_can_order_now.any?
  end

  def has_connectivity_feature_flags?
    has_centrally_managed_schools? || local_authority?
  end

  def has_multiple_chromebook_domains_in_managed_schools?
    active_schools.responsible_body_will_order_devices.filter_map(&:chromebook_domain).uniq.count > 1
  end

  def has_school_in_virtual_cap_pools?(school)
    vcap_schools.include?(school)
  end

  def has_schools_that_can_order_devices_now?
    active_schools.school_will_order_devices.that_can_order_now.any?
  end

  def has_virtual_cap_feature_flags_and_centrally_managed_schools?
    vcap_feature_flag? && has_centrally_managed_schools?
  end

  def humanized_type
    type.demodulize.underscore.humanize.downcase
  end

  def is_ordering_for_schools?
    has_centrally_managed_schools?
  end

  def is_ordering_for_all_schools?
    active_schools.count == active_schools.responsible_body_will_order_devices.count
  end

  def laptop?(device_type)
    device_type.to_sym == :laptop
  end

  def local_authority?
    type == 'LocalAuthority'
  end

  def next_school_sorted_ascending_by_name(school)
    active_schools
      .where('name > ?', school.name)
      .order(name: :asc)
      .first
  end

  def orders_managed_centrally?
    who_will_order_devices == 'responsible_body'
  end

  def orders_managed_by_schools?
    %w[school schools].include?(who_will_order_devices)
  end

  def calculate_virtual_caps!(device_types = %i[laptop router])
    recalculate_laptop_vcap if Array(device_types).include?(:laptop)
    recalculate_router_vcap if Array(device_types).include?(:router)
  end

  def recalculate_vcap(device_type)
    laptop?(device_type) ? recalculate_laptop_vcap : recalculate_router_vcap
  end

  def recalculate_laptop_vcap
    Rails.logger.info("***=== recalculating caps ===*** responsible_body_id: #{id} - laptops")
    values = vcap_schools.select('SUM(raw_laptop_allocation) as allocation_sum, SUM(raw_laptop_cap) as cap_sum, SUM(raw_laptops_ordered) as ordered_sum')[0]
    update!(laptop_allocation: values.allocation_sum.to_i,
            laptop_cap: values.cap_sum.to_i,
            laptops_ordered: values.ordered_sum.to_i)
    update_cap_on_computacenter(:laptop) if vcap_active? && (laptop_cap_previously_changed? || laptops_ordered_previously_changed?)
  end

  def recalculate_router_vcap
    Rails.logger.info("***=== recalculating caps ===*** responsible_body_id: #{id} - routers")
    values = vcap_schools.select('SUM(raw_router_allocation) as allocation_sum, SUM(raw_router_cap) as cap_sum, SUM(raw_routers_ordered) as ordered_sum')[0]
    update!(router_allocation: values.allocation_sum.to_i,
            router_cap: values.cap_sum.to_i,
            routers_ordered: values.ordered_sum.to_i)
    update_cap_on_computacenter(:router) if vcap_active? && (router_cap_previously_changed? || routers_ordered_previously_changed?)
  end
  #
  # def recalculate_laptop_vcap
  #   Rails.logger.info("***=== recalculating caps ===*** responsible_body_id: #{id} - laptops")
  #   update!(laptop_allocation: vcap_schools.sum(:raw_laptop_allocation),
  #           laptop_cap: vcap_schools.sum(:raw_laptop_cap),
  #           laptops_ordered: vcap_schools.sum(:raw_laptops_ordered))
  #   update_cap_on_computacenter(:laptop) if vcap_active? && (laptop_cap_previously_changed? || laptops_ordered_previously_changed?)
  # end
  #
  # def recalculate_router_vcap
  #   Rails.logger.info("***=== recalculating caps ===*** responsible_body_id: #{id} - routers")
  #   update!(router_allocation: vcap_schools.sum(:raw_router_allocation),
  #           router_cap: vcap_schools.sum(:raw_router_cap),
  #           routers_ordered: vcap_schools.sum(:raw_routers_ordered))
  #   update_cap_on_computacenter(:router) if vcap_active? && (router_cap_previously_changed? || routers_ordered_previously_changed?)
  # end

  def schools_by_order_status
    schools_by_name = active_schools.order(name: :asc)

    {
      ordering_schools: schools_by_name.can_order,
      specific_circumstances_schools: schools_by_name.can_order_for_specific_circumstances,
      fully_open_schools: schools_by_name.cannot_order,
    }
  end

  def single_academy_trust?
    organisation_type == 'single_academy_trust'
  end

  def trust?
    type == 'Trust'
  end

  def vcap_active?
    vcap_feature_flag? && orders_managed_centrally?
  end

  def vcap_schools
    return School.none unless vcap_active?

    schools
      .excluding_la_funded_provisions
      .responsible_body_will_order_devices
      .or(schools.who_will_order_devices_not_set)
  end

  def who_manages_orders_label
    case who_will_order_devices
    when 'school'
      'School or college'
    when 'schools'
      'Schools or colleges'
    when 'responsible_body'
      humanized_type.capitalize
    end
  end

private

  def maybe_generate_user_changes
    users.each(&:generate_user_change_if_needed!)
  end

  def set_computacenter_change
    self.computacenter_change = 'new'
  end

  def update_cap_on_computacenter(device_type)
    updates = vcap_schools.map { |school| school.cap_updates(device_type) }.flatten
    CapUpdateNotificationsService.new(*updates,
                                      notify_computacenter: false,
                                      notify_school: false).call
  end
end
