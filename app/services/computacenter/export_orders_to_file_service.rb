require 'csv'

# This service is used to export users to a CSV file.
class Computacenter::ExportOrdersToFileService < ExportToFileServiceBase
  def initialize(path, order_ids:)
    @path = path
    @report_service = Computacenter::ExportOrdersService
    @scope_ids = order_ids
  end
end
