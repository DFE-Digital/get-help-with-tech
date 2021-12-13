require 'csv'

# Service to export data
class DeviceSupplier::ExportAllocationsService < ExportServiceBase
  def initialize(scope_ids)
    @report_class = DeviceSupplier::AllocationReport
    @scope_ids = scope_ids
  end
end
