class VirtualCapPool < ApplicationRecord
  include Computacenter::CapChangeNotifier
  include DeviceType
  include DeviceCount

  belongs_to :responsible_body
  has_many :school_virtual_caps, dependent: :destroy
  has_many :school_device_allocations, through: :school_virtual_caps
  has_many :schools, through: :school_device_allocations

  after_touch :recalculate_caps!

  validates :device_type, uniqueness: { scope: :responsible_body_id }

  def self.with_std_device_first
    order(Arel.sql("device_type = 'coms_device' ASC"))
  end

  def recalculate_caps!
    self.cap = school_device_allocations.sum(:cap)
    self.devices_ordered = school_device_allocations.sum(:devices_ordered)
    self.allocation = school_device_allocations.sum(:allocation)
    save!
    notify_computacenter!
  end

  def add_school!(school)
    if school_can_be_added_to_pool?(school)
      add_school_allocation(school.device_allocations.find_by(device_type: device_type))
    else
      raise VirtualCapPoolError, "Cannot add school to virtual pool #{school.urn} #{school.name}"
    end
  end

  def has_school?(school)
    schools.exists?(school.id)
  end

private

  def school_can_be_added_to_pool?(school)
    school.responsible_body_id == responsible_body_id &&
      school&.preorder_information&.responsible_body_will_order_devices? &&
      (school.can_order? || school.can_order_for_specific_circumstances?) &&
      school.device_allocations.exists?(device_type: device_type) &&
      !school_virtual_caps.exists?(school_device_allocation: school.device_allocations.find_by(device_type: device_type))
  end

  def add_school_allocation(device_allocation)
    school_virtual_caps.create!(school_device_allocation: device_allocation)
    recalculate_caps!
  end

  def notify_computacenter!
    if FeatureFlag.active? :virtual_caps
      if notify_computacenter_of_cap_changes?
        allocation_ids = school_device_allocations.joins(:school).where(schools: { order_state: %w[can_order can_order_for_specific_circumstances] }).pluck(:id)
        update_cap_on_computacenter!(allocation_ids)
      end
    else
      Rails.logger.info("VirtualCapPool #{id}: (not) Notifying CC of changes (cap: #{cap}, devices_ordered: #{devices_ordered})")
    end
  end
end
