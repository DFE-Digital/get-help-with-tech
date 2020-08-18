class Computacenter::CapTypeConverter
  # computacenter cap type => SchoolDeviceAllocation.device_type
  CAP_TYPES_MAP = {
    'DfE_RemainThresholdQty|Std_Device' => 'std_device',
    'DfE_RemainThresholdQty|Coms_Device' => 'coms_device',
  }.freeze

  def self.to_dfe_type(cc_type)
    CAP_TYPES_MAP[cc_type]
  end

  def self.to_computacenter_type(dfe_type)
    CAP_TYPES_MAP.key(dfe_type).first
  end
end
