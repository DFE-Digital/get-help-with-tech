require 'csv'

# This service is used to export users to a CSV file.
class DeviceSupplier::ExportUsersService < ExportServiceBase
  def initialize(scope_ids)
    @report_class = DeviceSupplier::UserReport
    @scope_ids = scope_ids
  end
end
