require 'computacenter/responsible_body_urns'

class ResponsibleBody < ApplicationRecord
  has_one :bt_wifi_voucher_allocation
  belongs_to :key_contact, class_name: 'User', optional: true
  has_many :bt_wifi_vouchers
  has_many :users
  has_many :extra_mobile_data_requests
  has_many :schools

  extend Computacenter::ResponsibleBodyUrns::ClassMethods

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
    where('EXISTS(
        SELECT  preorder_information.id
        FROM    preorder_information
                          INNER JOIN schools
                                  ON schools.id = preorder_information.school_id
        WHERE   schools.responsible_body_id = responsible_bodies.id
          AND   status NOT IN (?)
      )', ['needs_info', 'needs_contact']
    )
  end
end
