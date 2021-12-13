require 'csv'

# This service is used to export users to a CSV file.
class ExportToFileServiceBase < ApplicationService
  def initialize(report_service, path, scope_ids:)
    @path = path
    @report_service = report_service
    @scope_ids = scope_ids
  end

  def call
    raise 'No path specified' if path.nil?

    File.write(path, report_service.call(scope_ids))
  end

private

  attr_reader :path, :report_service, :scope_ids
end
