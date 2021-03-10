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

  def self.can_order_std_devices_now
    by_device_type('std_device').where('cap > devices_ordered')
  end

  def self.by_device_type(device_type)
    where(device_type: device_type)
  end

  def self.by_computacenter_device_type(cc_device_type)
    by_device_type(Computacenter::CapTypeConverter.to_dfe_type(cc_device_type))
  end

  def computacenter_cap
    # value to pass to computacenter
    if has_virtual_cap_feature_flags?
      if is_in_virtual_cap_pool?
        # set the cap so the whole remaining pool amount could be ordered against this school
        # CC keep track of devices ordered by school. Assume devices_ordered has been correctly sync'd
        school_virtual_cap.adjusted_cap
      else
        raw_cap
      end
    else
      Rails.logger.info("Computacenter adjusted cap: #{school_virtual_cap.adjusted_cap}") if is_in_virtual_cap_pool?
      raw_cap
    end
  end

  def cap
    if has_virtual_cap_feature_flags?
      if is_in_virtual_cap_pool?
        school_virtual_cap.cap
      else
        super
      end
    else
      Rails.logger.info("Virtual cap: #{school_virtual_cap.cap}") if is_in_virtual_cap_pool?
      super
    end
  end

  def raw_cap
    self[:cap]
  end

  def devices_ordered
    if has_virtual_cap_feature_flags?
      if is_in_virtual_cap_pool?
        school_virtual_cap.devices_ordered
      else
        super
      end
    else
      Rails.logger.info("Virtual devices_ordered: #{school_virtual_cap.devices_ordered}") if is_in_virtual_cap_pool?
      super
    end
  end

  def raw_devices_ordered
    self[:devices_ordered]
  end

  def allocation
    if has_virtual_cap_feature_flags?
      if is_in_virtual_cap_pool?
        school_virtual_cap.allocation
      else
        super
      end
    else
      Rails.logger.info("Virtual allocation: #{school_virtual_cap.allocation}") if is_in_virtual_cap_pool?
      super
    end
  end

  def raw_allocation
    self[:allocation]
  end

  def is_in_virtual_cap_pool?
    school_virtual_cap.present?
  end

  def computacenter_cap_type
    Computacenter::CapTypeConverter.to_computacenter_type(device_type)
  end

  def cap_implied_by_order_state(order_state:, given_cap: nil)
    case order_state.to_sym
    when :cannot_order
      raw_devices_ordered.to_i
    when :can_order
      raw_allocation.to_i
    else # specific circumstances
      given_cap
    end
  end

private

  def has_virtual_cap_feature_flags?
    school&.responsible_body&.has_virtual_cap_feature_flags? || false
  end
end
