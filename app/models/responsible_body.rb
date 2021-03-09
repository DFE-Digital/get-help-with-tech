require 'computacenter/responsible_body_urns'

class ResponsibleBody < ApplicationRecord
  has_one :bt_wifi_voucher_allocation
  belongs_to :key_contact, class_name: 'User', optional: true
  has_many :bt_wifi_vouchers
  has_many :users
  has_many :extra_mobile_data_requests
  has_many :schools

  has_many :virtual_cap_pools, dependent: :destroy
  has_one :std_device_pool, -> { std_device }, class_name: 'VirtualCapPool'
  has_one :coms_device_pool, -> { coms_device }, class_name: 'VirtualCapPool'

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

  def calculate_virtual_caps!
    virtual_cap_pools.each(&:recalculate_caps!)
  end

  def add_school_to_virtual_cap_pools!(school)
    school.device_allocations.each do |allocation|
      pool = virtual_cap_pools.send(allocation.device_type).first_or_create!
      pool.add_school!(school)
    end
  end

  def has_devices_available_to_order?
    virtual_cap_pools.any?(&:has_devices_available_to_order?)
  end

  def has_school_in_virtual_cap_pools?(school)
    virtual_cap_pools.any? { |pool| pool.has_school?(school) }
  end

  def humanized_type
    type.demodulize.underscore.humanize.downcase
  end

  def is_a_trust?
    type == 'Trust'
  end

  def is_a_single_academy_trust?
    organisation_type == 'single_academy_trust'
  end

  def is_a_local_authority?
    type == 'LocalAuthority'
  end

  def is_a_further_education_college?
    type == 'FurtherEducationCollege'
  end

  def next_school_sorted_ascending_by_name(school)
    schools
      .where('name > ?', school.name)
      .order(name: :asc)
      .first
  end

  def update_who_will_order_devices(who_will_order)
    update!(who_will_order_devices: who_will_order)
    schools.each do |school|
      school.preorder_information&.destroy!
      school.create_preorder_information!(who_will_order_devices: who_will_order)
    end
  end

  def who_will_order_devices_label
    case who_will_order_devices
    when 'school'
      'School or college'
    when 'schools'
      'Schools or colleges'
    when 'responsible_body'
      humanized_type.capitalize
    end
  end

  def has_increased_allocation_feature_flags?
    FeatureFlag.active?(:increased_allocations_banner) && schools.any?(&:increased_allocations_feature_flag)
  end

  def has_virtual_cap_feature_flags?
    vcap_feature_flag?
  end

  def has_virtual_cap_feature_flags_and_centrally_managed_schools?
    has_virtual_cap_feature_flags? && has_centrally_managed_schools?
  end

  def has_connectivity_feature_flags?
    in_connectivity_pilot? && (has_centrally_managed_schools? || is_a_local_authority?)
  end

  def has_multiple_chromebook_domains_in_managed_schools?
    schools.gias_status_open.joins(:preorder_information).merge(PreorderInformation.responsible_body_will_order_devices).filter_map(&:chromebook_domain).uniq.count > 1
  end

  def self.in_connectivity_pilot
    where(in_connectivity_pilot: true)
  end

  def self.chosen_who_will_order
    where.not(who_will_order_devices: nil)
  end

  def self.with_at_least_one_preorder_information_completed
    where(
      'EXISTS(
        SELECT  preorder_information.id
        FROM    preorder_information
                          INNER JOIN schools
                                  ON schools.id = preorder_information.school_id
        WHERE   schools.responsible_body_id = responsible_bodies.id
          AND   preorder_information.status NOT IN (?)
      )', %w[needs_info needs_contact]
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

  def self.with_completed_preorder_info_count
    select(
      "
        (SELECT COUNT(*)
          FROM  schools INNER JOIN preorder_information
                                ON preorder_information.school_id = schools.id
          WHERE schools.responsible_body_id = responsible_bodies.id
            AND preorder_information.status NOT IN ('needs_info', 'needs_contact')
        ) AS completed_preorder_info_count
      ",
    )
  end

  def self.managing_multiple_chromebook_domains
    where(
      <<~SQL,
        id IN
          (SELECT rb_id FROM
            (SELECT DISTINCT s.responsible_body_id AS rb_id, p.school_or_rb_domain
              FROM schools s JOIN preorder_information p ON (p.school_id = s.id)
              WHERE s.status='open'
              AND p.who_will_order_devices='responsible_body'
              AND NOT (p.school_or_rb_domain = '' OR p.school_or_rb_domain IS NULL)
            ) AS t1
            GROUP BY t1.rb_id HAVING COUNT(*) > 1
          )
      SQL
    )
  end

  def is_ordering_for_schools?
    has_centrally_managed_schools?
  end

  def is_ordering_for_all_schools?
    schools.gias_status_open.count == schools.gias_status_open.that_are_centrally_managed.count
  end

  def has_centrally_managed_schools?
    schools.gias_status_open.that_are_centrally_managed.any?
  end

  def has_centrally_managed_schools_that_can_order_now?
    schools.gias_status_open.that_are_centrally_managed.that_can_order_now.any?
  end

  def has_schools_that_can_order_devices_now?
    schools.gias_status_open.that_will_order_devices.that_can_order_now.any?
  end

  def has_any_schools_that_can_order_now?
    schools.gias_status_open.that_can_order_now.any?
  end

  def schools_by_order_status
    schools_by_name = schools
      .includes(:preorder_information)
      .includes(:std_device_allocation)
      .gias_status_open
      .order(name: :asc)

    {
      ordering_schools: schools_by_name.can_order,
      specific_circumstances_schools: schools_by_name.can_order_for_specific_circumstances,
      fully_open_schools: schools_by_name.where(order_state: %w[cannot_order cannot_order_as_reopened]),
    }
  end

  def address
    [address_1, address_2, address_3, town, postcode].reject(&:blank?).join(', ')
  end

private

  def maybe_generate_user_changes
    users.each(&:generate_user_change_if_needed!)
  end

  def set_computacenter_change
    self.computacenter_change = 'new'
  end
end
