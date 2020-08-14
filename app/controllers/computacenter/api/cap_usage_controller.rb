class Computacenter::API::CapUsageController < Computacenter::API::BaseController
  def bulk_update
    logger.info "bulk_update, params = #{params}"
    validate_xml!(request.body.read, 'CapUsage.xsd')
  end
end
