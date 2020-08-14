class Computacenter::API::CapUsageUpdate
  attr_accessor :cap_type, :ship_to, :cap_amount, :cap_used, :status, :error

  # computacenter cap type => SchoolDeviceAllocation.device_type
  CAP_TYPES_MAP = {
    'DfE_RemainThresholdQty|Std_Device' => 'std_device',
    'DfE_RemainThresholdQty|Coms_Device' => 'coms_device',
  }.freeze

  # we'll get hashes with string keys from given XML
  # e.g. {"capType"=>"DfE_RemainThresholdQty|Std_Device", "shipTo"=>"81060874", "capAmount"=>"100", "usedCap"=>"20"}
  def initialize(string_keyed_hash = {})
    @cap_type = string_keyed_hash['capType']
    @ship_to = string_keyed_hash['shipTo']
    @cap_amount = string_keyed_hash['capAmount']
    @cap_used = string_keyed_hash['usedCap']
    @status = 'received'
    @error = nil
  end

  def apply!
    school = School.find_by_computacenter_reference!(ship_to)
    allocation = school.device_allocations.find_by_device_type!(CAP_TYPES_MAP[cap_type])
    log_cap_mismatch(allocation) if cap_amount != allocation.allocation
    allocation.update!(devices_ordered: cap_used)
    @status = 'succeeded'
  end

  def log_cap_mismatch(allocation)
    Rails.logger.warn("CapUsage mismatch: given capAmount: #{cap_amount}, SchoolDeviceAllocation: #{allocation.inspect}")
  end

  def succeeded?
    @status == 'succeeded'
  end

  def failed?
    @status == 'failed'
  end

  def fail!(error)
    @status = 'failed'
    @error = error
  end
end
