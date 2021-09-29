class SchoolDeviceAllocation < ApplicationRecord
  include DeviceType
  include DeviceCount

  has_paper_trail

  belongs_to :school, touch: true
  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :last_updated_by_user, class_name: 'User', optional: true
  has_one :school_virtual_cap, touch: true, dependent: :destroy

  has_many :cap_update_calls

  validates_with CapAndAllocationValidator

  scope :has_fully_ordered, -> { where('devices_ordered > 0 AND cap = devices_ordered') }
  scope :has_partially_ordered, -> { where('devices_ordered > 0 AND cap > devices_ordered') }
  scope :has_not_ordered, -> { where(devices_ordered: 0) }
  scope :has_not_fully_ordered, -> { where('cap > devices_ordered') }
  scope :by_device_type, ->(device_type) { where(device_type: device_type) }
  scope :can_order_std_devices_now, -> { by_device_type('std_device').where('cap > devices_ordered') }
  scope :by_computacenter_device_type, ->(cc_device_type) { by_device_type(Computacenter::CapTypeConverter.to_dfe_type(cc_device_type)) }

  delegate :computacenter_reference, :computacenter_references?, to: :school

  def allocation
    school.in_active_virtual_cap_pool? ? school_virtual_cap.allocation : super
  end

  def cap
    school.in_active_virtual_cap_pool? ? school_virtual_cap.cap : super
  end

  def computacenter_cap
    school.in_active_virtual_cap_pool? ? school_virtual_cap.adjusted_cap : raw_cap
  end

  def computacenter_cap_type
    Computacenter::CapTypeConverter.to_computacenter_type(device_type)
  end

  def devices_ordered
    school.in_active_virtual_cap_pool? ? school_virtual_cap.devices_ordered : super
  end

  def in_virtual_cap_pool?(**opts)
    return school_virtual_cap.present? unless opts[:responsible_body_id]

    school_virtual_cap&.responsible_body_id == opts[:responsible_body_id]
  end

  def raw_allocation
    self[:allocation]
  end

  def raw_cap
    self[:cap]
  end

  def raw_devices_ordered
    self[:devices_ordered]
  end

private

  def vcap_enabled?
    school&.responsible_body&.has_virtual_cap_feature_flags?
  end
end
