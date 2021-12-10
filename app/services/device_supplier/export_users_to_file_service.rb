require 'csv'

# This service is used to export users to a CSV file.
class DeviceSupplier::ExportUsersToFileService < ExportToFileServiceBase
  def initialize(path, user_ids:)
    @path = path
    @report_service = DeviceSupplier::ExportUsersService
    @scope_ids = user_ids
  end
end
