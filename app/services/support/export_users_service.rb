require 'csv'

# This service is used to export users to a CSV file.
class Support::ExportUsersService < ExportServiceBase
  def initialize(scope_ids)
    @report_class = Support::UserReport
    @scope_ids = scope_ids
  end
end
