require 'csv'

# This service is used to export users to a CSV file.
class DeviceSupplier::ExportAllocationsToFileService < ExportToFileServiceBase
  def initialize(path, school_ids:)
    @path = path
    @report_service = DeviceSupplier::ExportAllocationsService
    @scope_ids = school_ids
  end
end
