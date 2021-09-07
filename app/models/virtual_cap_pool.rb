class VirtualCapPool < ApplicationRecord
  include Computacenter::CapChangeNotifier
  include DeviceType
  include DeviceCount

  has_paper_trail

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
    Rails.logger.info("***=== recalculating caps ===*** pool-id: #{id}")
    self.cap = school_device_allocations.sum(:cap)
    self.devices_ordered = school_device_allocations.sum(:devices_ordered)
    self.allocation = school_device_allocations.sum(:allocation)

    notify_cc = cap_changed? || devices_ordered_changed?
    save!
    notify_computacenter! if notify_cc
  end

  def add_school!(school)
    if school_can_be_added_to_pool?(school)
      add_school_allocation!(school.device_allocations.find_by(device_type: device_type))
    else
      raise VirtualCapPoolError, "Cannot add school to virtual pool #{school.urn} #{school.name}"
    end
  end

  def remove_school!(school)
    school_device_allocation = school.device_allocations.find_by(device_type: device_type)
    remove_school_allocation!(school_device_allocation) if school_device_allocation
  end

  def has_school?(school)
    schools.exists?(school.id)
  end

private

  def school_can_be_added_to_pool?(school)
    school.responsible_body_id == responsible_body_id &&
      school&.preorder_information&.responsible_body_will_order_devices? &&
      school.device_allocations.exists?(device_type: device_type) &&
      !school_virtual_caps.exists?(school_device_allocation: school.device_allocations.find_by(device_type: device_type))
  end

  def add_school_allocation!(device_allocation)
    school_virtual_caps.create!(school_device_allocation: device_allocation)
    recalculate_caps!
  end

  def remove_school_allocation!(device_allocation)
    school_virtual_caps.find_by(school_device_allocation_id: device_allocation.id)&.destroy!
    recalculate_caps!
  end

  def notify_computacenter!
    if responsible_body.has_virtual_cap_feature_flags? && notify_computacenter_of_cap_changes?
      allocation_ids = school_device_allocations.select { |sda| sda.school.can_notify_computacenter? }.map(&:id)
      update_cap_on_computacenter!(allocation_ids)
    end
  end
end
