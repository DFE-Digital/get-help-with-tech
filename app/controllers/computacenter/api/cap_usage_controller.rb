class Computacenter::API::CapUsageController < Computacenter::API::BaseController
  def bulk_update
    logger.info "bulk_update, params = #{params}"
    validate_xml!('CapUsage.xsd')
    @batch = create_batch(@parsed_xml)
    @batch.process!
    render status: status_code(@batch)
  end

private

  def create_batch(parsed_xml)
    Computacenter::API::CapUsageUpdateBatch.new(parsed_xml['CapUsage'])
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
