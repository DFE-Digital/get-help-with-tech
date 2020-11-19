class Computacenter::API::CapUsageUpdate
  attr_accessor :cap_type, :ship_to, :cap_amount, :cap_used, :status, :error

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
    log_to_devices_ordered_updates
    CapMismatch.new(school, allocation).warn(cap_amount) if cap_amount != allocation.allocation
    original_devices_ordered = allocation.devices_ordered
    allocation.update!(devices_ordered: cap_used)
    school.preorder_information&.refresh_status!

    if cap_used.to_i < original_devices_ordered
      SchoolCanOrderDevicesNotifications.new(school: school).call
    end

    @status = 'succeeded'
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

  class CapMismatch
    attr_accessor :school, :allocation, :logger

    def initialize(school, allocation, logger = Rails.logger)
      @school = school
      @allocation = allocation
      @logger = logger
    end

    def warn(given_cap_amount)
      @logger.warn(cap_mismatch_message(given_cap_amount))
    end

    def cap_mismatch_message(cap_amount)
      "CapUsage mismatch: given capAmount: #{cap_amount}, school URN: #{school.urn}, SchoolDeviceAllocation: #{allocation.inspect}"
    end
  end

private

  def school
    @school ||= School.find_by_computacenter_reference!(ship_to)
  end

  def allocation
    @allocation ||= school.device_allocations.find_by_device_type!(Computacenter::CapTypeConverter.to_dfe_type(cap_type))
  end

  def log_to_devices_ordered_updates
    Computacenter::DevicesOrderedUpdate.create!(
      cap_type: cap_type,
      ship_to: ship_to,
      cap_amount: cap_amount,
      cap_used: cap_used,
    )
  end
end
