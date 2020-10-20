require 'computacenter/responsible_body_urns'

class ResponsibleBody < ApplicationRecord
  has_one :bt_wifi_voucher_allocation
  belongs_to :key_contact, class_name: 'User', optional: true
  has_many :bt_wifi_vouchers
  has_many :users
  has_many :extra_mobile_data_requests
  has_many :schools

  extend Computacenter::ResponsibleBodyUrns::ClassMethods
  include Computacenter::ResponsibleBodyUrns::InstanceMethods

  enum status: {
    open: 'open',
    closed: 'closed',
  }, _prefix: 'gias_status'

  def humanized_type
    type.demodulize.underscore.humanize.downcase
  end

  def is_a_trust?
    type == 'Trust'
  end

  def is_a_local_authority?
    type == 'LocalAuthority'
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
      school.create_preorder_information!(who_will_order_devices: who_will_order.singularize)
    end
  end

  def who_will_order_devices_label
    case who_will_order_devices
    when 'school'
      'School'
    when 'responsible_body'
      humanized_type.capitalize
    end
  end

  def self.in_devices_pilot
    where(in_devices_pilot: true)
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

  def self.with_users_who_have_signed_in_at_least_once
    select('(SELECT COUNT(*)  FROM  users
                              WHERE responsible_body_id=responsible_bodies.id
                                AND sign_in_count > 0)
            AS  users_who_have_signed_in_at_least_once')
  end

  def self.with_user_count
    select('(SELECT COUNT(*) FROM users WHERE responsible_body_id=responsible_bodies.id)
              AS user_count')
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

  def is_ordering_for_schools?
    schools.that_are_centrally_managed.any?
  end

  def has_centrally_managed_schools_that_can_order_now?
    schools.that_are_centrally_managed.that_can_order_now.any?
  end

  def has_schools_that_can_order_devices_now?
    schools.that_will_order_devices.that_can_order_now.any?
  end

  def has_any_schools_that_can_order_now?
    schools.that_can_order_now.any?
  end
end
