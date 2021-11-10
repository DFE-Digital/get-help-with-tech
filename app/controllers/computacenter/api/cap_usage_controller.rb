class Computacenter::API::CapUsageController < Computacenter::API::BaseController
  def bulk_update
    logger.info "bulk_update, params = #{params}"

    payload = Computacenter::API::CapUsageUpdatePayload.create!(payload_xml: @xml)
    validate_xml!('CapUsage.xsd')

    @batch = build_batch(@parsed_xml, payload.id)
    payload.update!(
      payload_id: @batch.payload_id,
      payload_timestamp: @batch.timestamp,
      records_count: @batch.updates.count,
    )

    @batch.process!
    payload.completed!(
      status: @batch.status,
      succeeded_count: @batch.succeeded_updates.count,
      failed_count: @batch.failed_updates.count,
    )

    render status: status_code(@batch)
  end

private

  def build_batch(parsed_xml, payload_id)
    Computacenter::API::CapUsageUpdateBatch.new(parsed_xml['CapUsage'], payload_id)
  end

  def status_code(batch)
    if batch.succeeded?
      :ok
    elsif batch.failed?
      :unprocessable_entity
    else
      :multi_status
    end
  end
end
