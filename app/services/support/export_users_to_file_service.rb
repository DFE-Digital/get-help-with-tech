require 'csv'

# This service is used to export users to a CSV file.
class Support::ExportUsersToFileService < ExportToFileServiceBase
  def initialize(path, user_ids:)
    @path = path
    @report_service = Support::ExportUsersService
    @scope_ids = user_ids
  end
end
