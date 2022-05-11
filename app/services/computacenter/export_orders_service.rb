require 'csv'

# Service to export data
class Computacenter::ExportOrdersService < ExportServiceBase
  def initialize(scope_ids)
    @report_class = Computacenter::OrderReport
    @scope_ids = scope_ids
  end
end
