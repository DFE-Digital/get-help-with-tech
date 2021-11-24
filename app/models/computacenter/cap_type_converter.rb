class Computacenter::CapTypeConverter
  CAP_TYPES_MAP = {
    laptop: 'DfE_RemainThresholdQty|Std_Device',
    router: 'DfE_RemainThresholdQty|Coms_Device',
  }.freeze

  def self.to_dfe_type(cc_type)
    CAP_TYPES_MAP.key(cc_type)
  end

  def self.to_computacenter_type(dfe_type)
    CAP_TYPES_MAP[dfe_type]
  end
end
