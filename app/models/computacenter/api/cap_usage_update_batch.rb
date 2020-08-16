class Computacenter::API::CapUsageUpdateBatch
  attr_accessor :payload_id, :timestamp, :updates

  def initialize(string_keyed_hash)
    @payload_id = string_keyed_hash['payloadID']
    @timestamp  = string_keyed_hash['dateTime']&.to_datetime
    @updates    = string_keyed_hash['Record'].to_a.map do |update|
      Computacenter::API::CapUsageUpdate.new(update)
    end
  end

  def process!
    Rails.logger.info "Processing CapUsageUpdateBatch with payload_id #{payload_id}"
    @updates.each do |update|
      Rails.logger.info "Processing CapUsageUpdate #{update}"
      apply_update_and_catch_errors(update)
    end
  end

  def apply_update_and_catch_errors(update)
    update.apply!
  rescue ActiveRecord::RecordNotFound => e
    update.fail! e.message
  end

  def status
    if @updates.all?(&:succeeded?)
      'succeeded'
    elsif @updates.all?(&:failed?)
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

  def failed_updates
    updates.select(&:failed?)
  end
end
