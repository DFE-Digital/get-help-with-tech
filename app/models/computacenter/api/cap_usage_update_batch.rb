class Computacenter::API::CapUsageUpdateBatch
  attr_accessor :notify_decreases, :payload_id, :timestamp, :updates

  def initialize(string_keyed_hash, cap_usage_update_payload_id = nil)
    @cap_usage_update_payload_id = cap_usage_update_payload_id
    @payload_id = string_keyed_hash['payloadID']
    @timestamp  = string_keyed_hash['dateTime']&.to_datetime
    @updates    = Array.wrap(string_keyed_hash['Record']).map do |update|
      Computacenter::API::CapUsageUpdate.new(update)
    end
    @notify_decreases = FeatureFlag.active?(:notify_when_cap_usage_decreases)
  end

  def process!
    Rails.logger.info "Processing CapUsageUpdateBatch with payload_id #{payload_id}"
    updates.each do |update|
      Rails.logger.info "Processing CapUsageUpdate #{update}"
      apply_update_and_catch_errors(update)
    end
  end

  def apply_update_and_catch_errors(update)
    update.apply!(notify_decreases:, cap_usage_update_payload_id: @cap_usage_update_payload_id)
  rescue ActiveRecord::RecordNotFound => e
    update.fail! e.message
  end

  def status
    if updates.all?(&:succeeded?)
      'succeeded'
    elsif updates.all?(&:failed?)
      'failed'
    else
      'partially_failed'
    end
  end

  def succeeded?
    status == 'succeeded'
  end

  def failed?
    status == 'failed'
  end

  def partially_failed?
    status == 'partially_failed'
  end

  def succeeded_updates
    updates.select(&:succeeded?)
  end

  def failed_updates
    updates.select(&:failed?)
  end
end
