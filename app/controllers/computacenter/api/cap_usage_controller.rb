class Computacenter::API::CapUsageController < Computacenter::API::BaseController

  def bulk_update
    logger.info "bulk_update, params = #{params}"
    validate_xml!('CapUsage.xsd')
    @batch = Computacenter::API::CapUsageUpdateBatch.new(@parsed_xml['CapUsage'])
    @batch.process!
    render status: status_code(@batch)
  end

private

  def status_code(batch)
    if batch.succeeded?
      :updated
    elsif batch.failed?
      :unprocessable_entity
    else
      :multi_status
    end
  end
end
