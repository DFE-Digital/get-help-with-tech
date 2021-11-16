class VirtualCapPool < ApplicationRecord
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
    save!
    update_cap_on_computacenter if enabled? && (cap_previously_changed? || devices_ordered_previously_changed?)
  end

  def has_school?(school)
    schools.exists?(school.id)
  end

private

  def enabled?
    responsible_body.vcap?
  end

  def update_cap_on_computacenter
    CapUpdateNotificationsService.new(*school_device_allocation_ids,
                                      notify_computacenter: false,
                                      notify_school: false).call
  end
end
